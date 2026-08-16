from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy import select, and_
from app.database import get_db, init_db
from app.models import (
    User, PersonalProfile, Space, SpaceMembership, Recipe, RecipeIngredient, 
    RecipeStep, RecipeNutrition, WeightEntry, StepEntry, TrainingSession,
    ShoppingList, ShoppingListItem
)
from app.schemas import *
from app.auth import (
    get_password_hash, verify_password, create_access_token, create_refresh_token,
    get_current_active_user
)
import uuid
from datetime import datetime, timedelta
import secrets
import string

app = FastAPI(
    title="Project Nutrition API",
    version="0.1.0",
    description="Backend API for Project Nutrition MVP"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
async def startup():
    init_db()

# Health check
@app.get("/health")
async def health_check():
    return {"status": "ok", "version": "0.1.0"}

# Authentication
@app.post("/api/v1/auth/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def register(user_data: UserCreate, db: Session = Depends(get_db)):
    # Check if user exists
    result = db.execute(select(User).where(User.email == user_data.email))
    existing_user = result.scalar_one_or_none()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    # Create user
    user_id = str(uuid.uuid4())
    user = User(
        id=user_id,
        email=user_data.email,
        password_hash=get_password_hash(user_data.password),
        display_name=user_data.display_name,
        status="active",
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow()
    )
    db.add(user)
    
    # Create default profile
    profile = PersonalProfile(
        id=str(uuid.uuid4()),
        user_id=user_id,
        timezone="Europe/Berlin",
        preferred_units="metric",
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow()
    )
    db.add(profile)
    
    db.commit()
    db.refresh(user)
    
    # Create tokens
    access_token = create_access_token({"sub": user.id})
    refresh_token = create_refresh_token({"sub": user.id})
    
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        expires_in=1800,
        user=UserResponse.model_validate(user)
    )

@app.post("/api/v1/auth/login", response_model=TokenResponse)
async def login(login_data: UserLogin, db: Session = Depends(get_db)):
    result = db.execute(select(User).where(User.email == login_data.email))
    user = result.scalar_one_or_none()
    
    if not user or not verify_password(login_data.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    
    access_token = create_access_token({"sub": user.id})
    refresh_token = create_refresh_token({"sub": user.id})
    
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        expires_in=1800,
        user=UserResponse.model_validate(user)
    )

@app.post("/api/v1/auth/refresh", response_model=TokenResponse)
async def refresh_token(refresh_data: RefreshTokenRequest, db: Session = Depends(get_db)):
    from jose import jwt, JWTError
    from app.auth import SECRET_KEY, ALGORITHM
    
    try:
        payload = jwt.decode(refresh_data.refresh_token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        token_type: str = payload.get("type")
        
        if user_id is None or token_type != "refresh":
            raise HTTPException(status_code=401, detail="Invalid refresh token")
            
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid refresh token")
    
    result = db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    
    if user is None:
        raise HTTPException(status_code=401, detail="User not found")
    
    access_token = create_access_token({"sub": user.id})
    refresh_token = create_refresh_token({"sub": user.id})
    
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        expires_in=1800,
        user=UserResponse.model_validate(user)
    )

# User endpoints
@app.get("/api/v1/users/me", response_model=UserResponse)
async def get_current_user_info(current_user: User = Depends(get_current_active_user)):
    return UserResponse.model_validate(current_user)

@app.get("/api/v1/users/me/profile", response_model=PersonalProfileResponse)
async def get_user_profile(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    result = db.execute(
        select(PersonalProfile).where(PersonalProfile.user_id == current_user.id)
    )
    profile = result.scalar_one_or_none()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    return PersonalProfileResponse.model_validate(profile)

@app.put("/api/v1/users/me/profile", response_model=PersonalProfileResponse)
async def update_user_profile(
    profile_data: PersonalProfileCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    result = db.execute(
        select(PersonalProfile).where(PersonalProfile.user_id == current_user.id)
    )
    profile = result.scalar_one_or_none()
    
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    for field, value in profile_data.model_dump().items():
        setattr(profile, field, value)
    
    profile.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(profile)
    
    return PersonalProfileResponse.model_validate(profile)

# Space endpoints
@app.post("/api/v1/spaces", response_model=SpaceResponse, status_code=status.HTTP_201_CREATED)
async def create_space(
    space_data: SpaceCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    # Generate invite code
    invite_code = ''.join(secrets.choice(string.ascii_uppercase + string.digits) for _ in range(8))
    
    space = Space(
        id=str(uuid.uuid4()),
        name=space_data.name,
        owner_user_id=current_user.id,
        status="active",
        invite_code=invite_code,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow()
    )
    db.add(space)
    db.flush()
    
    # Add creator as owner
    membership = SpaceMembership(
        id=str(uuid.uuid4()),
        space_id=space.id,
        user_id=current_user.id,
        role="owner",
        status="active",
        joined_at=datetime.utcnow()
    )
    db.add(membership)
    db.commit()
    db.refresh(space)
    
    return SpaceResponse.model_validate(space)

@app.get("/api/v1/spaces", response_model=list[SpaceResponse])
async def get_user_spaces(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    result = db.execute(
        select(Space)
        .join(SpaceMembership, SpaceMembership.space_id == Space.id)
        .where(SpaceMembership.user_id == current_user.id)
        .where(SpaceMembership.status == "active")
    )
    spaces = result.scalars().all()
    return [SpaceResponse.model_validate(s) for s in spaces]

@app.get("/api/v1/spaces/{space_id}", response_model=SpaceWithMembersResponse)
async def get_space(
    space_id: str,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    # Check membership
    membership_result = db.execute(
        select(SpaceMembership).where(
            and_(SpaceMembership.space_id == space_id, SpaceMembership.user_id == current_user.id)
        )
    )
    membership = membership_result.scalar_one_or_none()
    if not membership:
        raise HTTPException(status_code=403, detail="Not a member of this space")
    
    result = db.execute(select(Space).where(Space.id == space_id))
    space = result.scalar_one_or_none()
    
    if not space:
        raise HTTPException(status_code=404, detail="Space not found")
    
    # Get members separately
    members_result = db.execute(
        select(SpaceMembership, User)
        .join(User, User.id == SpaceMembership.user_id)
        .where(SpaceMembership.space_id == space_id)
    )
    members = []
    for membership_row, user in members_result:
        members.append(SpaceMembershipResponse(
            id=membership_row.id,
            space_id=membership_row.space_id,
            user_id=membership_row.user_id,
            role=membership_row.role,
            status=membership_row.status,
            joined_at=membership_row.joined_at,
            user=UserResponse.model_validate(user)
        ))
    
    return SpaceWithMembersResponse(
        id=space.id,
        name=space.name,
        owner_user_id=space.owner_user_id,
        status=space.status,
        invite_code=space.invite_code,
        created_at=space.created_at,
        updated_at=space.updated_at,
        members=members
    )

@app.post("/api/v1/spaces/join", response_model=SpaceResponse)
async def join_space(
    join_data: JoinSpaceRequest,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    # Find space by invite code
    result = db.execute(
        select(Space).where(Space.invite_code == join_data.invite_code.upper())
    )
    space = result.scalar_one_or_none()
    
    if not space:
        raise HTTPException(status_code=404, detail="Invalid invite code")
    
    # Check if already member
    existing_result = db.execute(
        select(SpaceMembership).where(
            and_(SpaceMembership.space_id == space.id, SpaceMembership.user_id == current_user.id)
        )
    )
    existing = existing_result.scalar_one_or_none()
    if existing:
        raise HTTPException(status_code=400, detail="Already a member of this space")
    
    # Create membership
    membership = SpaceMembership(
        id=str(uuid.uuid4()),
        space_id=space.id,
        user_id=current_user.id,
        role="member",
        status="active",
        joined_at=datetime.utcnow()
    )
    db.add(membership)
    db.commit()
    db.refresh(space)
    
    return SpaceResponse.model_validate(space)

# Recipe endpoints
@app.post("/api/v1/recipes", response_model=RecipeResponse, status_code=status.HTTP_201_CREATED)
async def create_recipe(
    recipe_data: RecipeCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    recipe = Recipe(
        id=str(uuid.uuid4()),
        owner_type="user",
        owner_user_id=current_user.id,
        title=recipe_data.title,
        description=recipe_data.description,
        default_servings=recipe_data.default_servings,
        preparation_time_minutes=recipe_data.preparation_time_minutes,
        cooking_time_minutes=recipe_data.cooking_time_minutes,
        difficulty=recipe_data.difficulty,
        visibility=recipe_data.visibility,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow()
    )
    db.add(recipe)
    db.flush()
    
    # Add ingredients
    for idx, ing in enumerate(recipe_data.ingredients):
        ingredient = RecipeIngredient(
            id=str(uuid.uuid4()),
            recipe_id=recipe.id,
            ingredient_name=ing.ingredient_name,
            quantity=ing.quantity,
            unit=ing.unit,
            category=ing.category,
            optional=ing.optional,
            sort_order=idx
        )
        db.add(ingredient)
    
    # Add steps
    for idx, step in enumerate(recipe_data.steps):
        step_obj = RecipeStep(
            id=str(uuid.uuid4()),
            recipe_id=recipe.id,
            instruction=step.instruction,
            sort_order=idx,
            duration_minutes=step.duration_minutes
        )
        db.add(step_obj)
    
    # Add nutrition
    if recipe_data.nutrition:
        nutrition = RecipeNutrition(
            id=str(uuid.uuid4()),
            recipe_id=recipe.id,
            basis=recipe_data.nutrition.basis,
            calories=recipe_data.nutrition.calories,
            protein_g=recipe_data.nutrition.protein_g,
            fat_g=recipe_data.nutrition.fat_g,
            carbohydrate_g=recipe_data.nutrition.carbohydrate_g,
            fiber_g=recipe_data.nutrition.fiber_g
        )
        db.add(nutrition)
    
    db.commit()
    db.refresh(recipe)
    
    return RecipeResponse.model_validate(recipe)

@app.get("/api/v1/recipes", response_model=list[RecipeResponse])
async def get_user_recipes(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    result = db.execute(
        select(Recipe).where(Recipe.owner_user_id == current_user.id)
    )
    recipes = result.scalars().all()
    return [RecipeResponse.model_validate(r) for r in recipes]

# Weight tracking
@app.post("/api/v1/tracking/weight", response_model=WeightEntryResponse, status_code=status.HTTP_201_CREATED)
async def create_weight_entry(
    entry_data: WeightEntryCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    entry = WeightEntry(
        id=str(uuid.uuid4()),
        user_id=current_user.id,
        weight_kg=entry_data.weight_kg,
        measured_at=entry_data.measured_at,
        notes=entry_data.notes,
        source="manual",
        created_at=datetime.utcnow()
    )
    db.add(entry)
    
    # Update current weight in profile
    result = db.execute(
        select(PersonalProfile).where(PersonalProfile.user_id == current_user.id)
    )
    profile = result.scalar_one_or_none()
    if profile:
        profile.current_weight_kg = entry_data.weight_kg
        profile.updated_at = datetime.utcnow()
    
    db.commit()
    db.refresh(entry)
    
    return WeightEntryResponse.model_validate(entry)

@app.get("/api/v1/tracking/weight", response_model=list[WeightEntryResponse])
async def get_weight_history(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    result = db.execute(
        select(WeightEntry)
        .where(WeightEntry.user_id == current_user.id)
        .order_by(WeightEntry.measured_at.desc())
    )
    entries = result.scalars().all()
    return [WeightEntryResponse.model_validate(e) for e in entries]

# Step tracking
@app.post("/api/v1/tracking/steps", response_model=StepEntryResponse, status_code=status.HTTP_201_CREATED)
async def create_step_entry(
    entry_data: StepEntryCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    entry = StepEntry(
        id=str(uuid.uuid4()),
        user_id=current_user.id,
        steps=entry_data.steps,
        date=datetime.combine(entry_data.date, datetime.min.time()),
        source="manual",
        created_at=datetime.utcnow()
    )
    db.add(entry)
    db.commit()
    db.refresh(entry)
    
    return StepEntryResponse.model_validate(entry)

@app.get("/api/v1/tracking/steps", response_model=list[StepEntryResponse])
async def get_step_history(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    result = db.execute(
        select(StepEntry)
        .where(StepEntry.user_id == current_user.id)
        .order_by(StepEntry.date.desc())
    )
    entries = result.scalars().all()
    return [StepEntryResponse.model_validate(e) for e in entries]

# Training
@app.post("/api/v1/training", response_model=TrainingSessionResponse, status_code=status.HTTP_201_CREATED)
async def create_training_session(
    session_data: TrainingSessionCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    session = TrainingSession(
        id=str(uuid.uuid4()),
        user_id=current_user.id,
        created_by_user_id=current_user.id,
        title=session_data.title,
        session_type=session_data.session_type,
        date=session_data.date,
        target_duration_minutes=session_data.target_duration_minutes,
        target_steps=session_data.target_steps,
        notes=session_data.notes,
        visibility=session_data.visibility,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow()
    )
    db.add(session)
    db.commit()
    db.refresh(session)
    
    return TrainingSessionResponse.model_validate(session)

@app.get("/api/v1/training", response_model=list[TrainingSessionResponse])
async def get_training_sessions(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    result = db.execute(
        select(TrainingSession)
        .where(TrainingSession.user_id == current_user.id)
        .order_by(TrainingSession.date.desc())
    )
    sessions = result.scalars().all()
    return [TrainingSessionResponse.model_validate(s) for s in sessions]

# Shopping list
@app.post("/api/v1/shopping-lists", response_model=ShoppingListResponse, status_code=status.HTTP_201_CREATED)
async def create_shopping_list(
    list_data: ShoppingListCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    shopping_list = ShoppingList(
        id=str(uuid.uuid4()),
        owner_type="user",
        owner_user_id=current_user.id,
        name=list_data.name,
        status="active",
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow()
    )
    db.add(shopping_list)
    db.commit()
    db.refresh(shopping_list)
    
    return ShoppingListResponse.model_validate(shopping_list)

@app.get("/api/v1/shopping-lists", response_model=list[ShoppingListResponse])
async def get_shopping_lists(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    result = db.execute(
        select(ShoppingList)
        .where(ShoppingList.owner_user_id == current_user.id)
        .order_by(ShoppingList.created_at.desc())
    )
    lists = result.scalars().all()
    return [ShoppingListResponse.model_validate(l) for l in lists]

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)