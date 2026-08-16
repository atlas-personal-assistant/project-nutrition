from pydantic import BaseModel, EmailStr, Field
from datetime import datetime, date
from typing import Optional, List
from uuid import UUID

# User schemas
class UserCreate(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6)
    display_name: str = Field(..., min_length=1, max_length=255)

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id: str
    email: str
    display_name: str
    status: str
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int
    user: UserResponse

class RefreshTokenRequest(BaseModel):
    refresh_token: str

# Profile schemas
class PersonalProfileCreate(BaseModel):
    birth_date: Optional[date] = None
    biological_sex: Optional[str] = None
    height_cm: Optional[float] = None
    activity_level: Optional[str] = None
    timezone: str = "Europe/Berlin"
    preferred_units: str = "metric"

class PersonalProfileResponse(BaseModel):
    id: str
    user_id: str
    birth_date: Optional[date]
    biological_sex: Optional[str]
    height_cm: Optional[float]
    current_weight_kg: Optional[float]
    activity_level: Optional[str]
    timezone: str
    preferred_units: str
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

# Space schemas
class SpaceCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)

class SpaceResponse(BaseModel):
    id: str
    name: str
    owner_user_id: str
    status: str
    invite_code: Optional[str]
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class SpaceMembershipResponse(BaseModel):
    id: str
    space_id: str
    user_id: str
    role: str
    status: str
    joined_at: datetime
    user: Optional[UserResponse] = None
    
    class Config:
        from_attributes = True

class SpaceWithMembersResponse(BaseModel):
    id: str
    name: str
    owner_user_id: str
    status: str
    invite_code: Optional[str]
    created_at: datetime
    updated_at: datetime
    members: List[SpaceMembershipResponse]
    
    class Config:
        from_attributes = True

class JoinSpaceRequest(BaseModel):
    invite_code: str = Field(..., min_length=6, max_length=20)

# Recipe schemas
class RecipeIngredientCreate(BaseModel):
    ingredient_name: str
    quantity: Optional[float] = None
    unit: Optional[str] = None
    category: Optional[str] = None
    optional: bool = False

class RecipeStepCreate(BaseModel):
    instruction: str
    duration_minutes: Optional[int] = None

class RecipeNutritionCreate(BaseModel):
    basis: str = "per_serving"
    calories: Optional[float] = None
    protein_g: Optional[float] = None
    fat_g: Optional[float] = None
    carbohydrate_g: Optional[float] = None
    fiber_g: Optional[float] = None

class RecipeCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    default_servings: int = 1
    preparation_time_minutes: Optional[int] = None
    cooking_time_minutes: Optional[int] = None
    difficulty: Optional[str] = None
    visibility: str = "private"
    ingredients: List[RecipeIngredientCreate] = []
    steps: List[RecipeStepCreate] = []
    nutrition: Optional[RecipeNutritionCreate] = None

class RecipeResponse(BaseModel):
    id: str
    owner_type: str
    owner_user_id: Optional[str]
    owner_space_id: Optional[str]
    title: str
    description: Optional[str]
    default_servings: int
    preparation_time_minutes: Optional[int]
    cooking_time_minutes: Optional[int]
    difficulty: Optional[str]
    visibility: str
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

# Weight tracking schemas
class WeightEntryCreate(BaseModel):
    weight_kg: float = Field(..., gt=0)
    measured_at: datetime
    notes: Optional[str] = None

class WeightEntryResponse(BaseModel):
    id: str
    user_id: str
    measured_at: datetime
    weight_kg: float
    source: str
    notes: Optional[str]
    created_at: datetime
    
    class Config:
        from_attributes = True

# Step tracking schemas
class StepEntryCreate(BaseModel):
    steps: int = Field(..., gt=0)
    date: date

class StepEntryResponse(BaseModel):
    id: str
    user_id: str
    date: date
    steps: int
    source: str
    created_at: datetime
    
    class Config:
        from_attributes = True

# Training schemas
class TrainingSessionCreate(BaseModel):
    title: str
    session_type: str
    date: datetime
    target_duration_minutes: Optional[int] = None
    target_steps: Optional[int] = None
    notes: Optional[str] = None
    visibility: str = "private"

class TrainingSessionResponse(BaseModel):
    id: str
    user_id: str
    title: str
    session_type: str
    date: datetime
    target_duration_minutes: Optional[int]
    target_steps: Optional[int]
    notes: Optional[str]
    visibility: str
    created_at: datetime
    
    class Config:
        from_attributes = True

# Shopping list schemas
class ShoppingListItemCreate(BaseModel):
    name: str
    quantity: Optional[float] = None
    unit: Optional[str] = None
    category: Optional[str] = None

class ShoppingListItemResponse(BaseModel):
    id: str
    shopping_list_id: str
    name: str
    quantity: Optional[float]
    unit: Optional[str]
    category: Optional[str]
    checked: bool
    manually_added: bool
    created_at: datetime
    
    class Config:
        from_attributes = True

class ShoppingListCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)

class ShoppingListResponse(BaseModel):
    id: str
    owner_type: str
    name: str
    status: str
    created_at: datetime
    updated_at: datetime
    items: List[ShoppingListItemResponse] = []
    
    class Config:
        from_attributes = True