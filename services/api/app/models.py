from sqlalchemy import Column, String, DateTime, Integer, Float, Boolean, ForeignKey, Text, Enum, Table
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.database import Base
import uuid
from datetime import datetime
import enum

class UserStatus(str, enum.Enum):
    ACTIVE = "active"
    INACTIVE = "inactive"
    PENDING = "pending"

class SpaceRole(str, enum.Enum):
    OWNER = "owner"
    MEMBER = "member"

class SpaceStatus(str, enum.Enum):
    ACTIVE = "active"
    INACTIVE = "inactive"

class MealType(str, enum.Enum):
    BREAKFAST = "breakfast"
    LUNCH = "lunch"
    DINNER = "dinner"
    SNACK = "snack"
    OTHER = "other"

class ParticipationStatus(str, enum.Enum):
    PLANNED = "planned"
    CONFIRMED = "confirmed"
    SKIPPED = "skipped"
    COMPLETED = "completed"

class ShoppingItemStatus(str, enum.Enum):
    PENDING = "pending"
    CHECKED = "checked"

class TrainingType(str, enum.Enum):
    STRENGTH = "strength"
    CARDIO = "cardio"
    WALKING = "walking"
    MOBILITY = "mobility"
    RECOVERY = "recovery"
    OTHER = "other"

class CompletionStatus(str, enum.Enum):
    PLANNED = "planned"
    COMPLETED = "completed"
    SKIPPED = "skipped"

class User(Base):
    __tablename__ = "users"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    email = Column(String(255), unique=True, nullable=False, index=True)
    password_hash = Column(String(255), nullable=False)
    display_name = Column(String(255), nullable=False)
    status = Column(String(50), default=UserStatus.ACTIVE)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    profile = relationship("PersonalProfile", back_populates="user", uselist=False, cascade="all, delete-orphan")
    space_memberships = relationship("SpaceMembership", back_populates="user", cascade="all, delete-orphan")
    created_spaces = relationship("Space", back_populates="owner")
    weight_entries = relationship("WeightEntry", back_populates="user", cascade="all, delete-orphan")
    step_entries = relationship("StepEntry", back_populates="user", cascade="all, delete-orphan")
    nutrition_goals = relationship("NutritionGoal", back_populates="user", cascade="all, delete-orphan")
    activity_goals = relationship("ActivityGoal", back_populates="user", cascade="all, delete-orphan")
    training_sessions = relationship("TrainingSession", back_populates="user", foreign_keys="TrainingSession.user_id", cascade="all, delete-orphan")

class PersonalProfile(Base):
    __tablename__ = "personal_profiles"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id"), unique=True, nullable=False)
    birth_date = Column(DateTime(timezone=True), nullable=True)
    biological_sex = Column(String(50), nullable=True)
    height_cm = Column(Float, nullable=True)
    current_weight_kg = Column(Float, nullable=True)
    activity_level = Column(String(50), nullable=True)
    timezone = Column(String(100), default="Europe/Berlin")
    preferred_units = Column(String(50), default="metric")
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    
    user = relationship("User", back_populates="profile")

class Space(Base):
    __tablename__ = "spaces"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String(255), nullable=False)
    owner_user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    status = Column(String(50), default=SpaceStatus.ACTIVE)
    invite_code = Column(String(20), unique=True, nullable=True, index=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    
    owner = relationship("User", back_populates="created_spaces")
    memberships = relationship("SpaceMembership", back_populates="space", cascade="all, delete-orphan")
    meal_plans = relationship("MealPlan", back_populates="space", cascade="all, delete-orphan")
    shopping_lists = relationship("ShoppingList", back_populates="space", cascade="all, delete-orphan")
    recipes = relationship("Recipe", back_populates="space", cascade="all, delete-orphan")

class SpaceMembership(Base):
    __tablename__ = "space_memberships"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    space_id = Column(String(36), ForeignKey("spaces.id"), nullable=False)
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    role = Column(String(50), default=SpaceRole.MEMBER)
    status = Column(String(50), default="active")
    joined_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    left_at = Column(DateTime(timezone=True), nullable=True)
    
    space = relationship("Space", back_populates="memberships")
    user = relationship("User", back_populates="space_memberships")

class Recipe(Base):
    __tablename__ = "recipes"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    owner_type = Column(String(50), nullable=False)  # 'user', 'space', 'system'
    owner_user_id = Column(String(36), ForeignKey("users.id"), nullable=True)
    owner_space_id = Column(String(36), ForeignKey("spaces.id"), nullable=True)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    default_servings = Column(Integer, default=1)
    preparation_time_minutes = Column(Integer, nullable=True)
    cooking_time_minutes = Column(Integer, nullable=True)
    difficulty = Column(String(50), nullable=True)
    visibility = Column(String(50), default="private")
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    
    space = relationship("Space", back_populates="recipes")
    ingredients = relationship("RecipeIngredient", back_populates="recipe", cascade="all, delete-orphan")
    steps = relationship("RecipeStep", back_populates="recipe", cascade="all, delete-orphan")
    nutrition = relationship("RecipeNutrition", back_populates="recipe", uselist=False, cascade="all, delete-orphan")

class RecipeIngredient(Base):
    __tablename__ = "recipe_ingredients"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    recipe_id = Column(String(36), ForeignKey("recipes.id"), nullable=False)
    ingredient_name = Column(String(255), nullable=False)
    quantity = Column(Float, nullable=True)
    unit = Column(String(50), nullable=True)
    category = Column(String(100), nullable=True)
    optional = Column(Boolean, default=False)
    sort_order = Column(Integer, default=0)
    
    recipe = relationship("Recipe", back_populates="ingredients")

class RecipeStep(Base):
    __tablename__ = "recipe_steps"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    recipe_id = Column(String(36), ForeignKey("recipes.id"), nullable=False)
    instruction = Column(Text, nullable=False)
    sort_order = Column(Integer, default=0)
    duration_minutes = Column(Integer, nullable=True)
    
    recipe = relationship("Recipe", back_populates="steps")

class RecipeNutrition(Base):
    __tablename__ = "recipe_nutrition"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    recipe_id = Column(String(36), ForeignKey("recipes.id"), nullable=False)
    basis = Column(String(50), default="per_serving")  # 'whole_recipe' or 'per_serving'
    calories = Column(Float, nullable=True)
    protein_g = Column(Float, nullable=True)
    fat_g = Column(Float, nullable=True)
    carbohydrate_g = Column(Float, nullable=True)
    fiber_g = Column(Float, nullable=True)
    
    recipe = relationship("Recipe", back_populates="nutrition")

class MealPlan(Base):
    __tablename__ = "meal_plans"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    owner_type = Column(String(50), nullable=False)  # 'user' or 'space'
    owner_user_id = Column(String(36), ForeignKey("users.id"), nullable=True)
    owner_space_id = Column(String(36), ForeignKey("spaces.id"), nullable=True)
    start_date = Column(DateTime(timezone=True), nullable=False)
    end_date = Column(DateTime(timezone=True), nullable=False)
    status = Column(String(50), default="active")
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    
    space = relationship("Space", back_populates="meal_plans")
    planned_meals = relationship("PlannedMeal", back_populates="meal_plan", cascade="all, delete-orphan")

class PlannedMeal(Base):
    __tablename__ = "planned_meals"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    meal_plan_id = Column(String(36), ForeignKey("meal_plans.id"), nullable=False)
    space_id = Column(String(36), ForeignKey("spaces.id"), nullable=True)
    created_by_user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    date = Column(DateTime(timezone=True), nullable=False)
    meal_type = Column(String(50), nullable=False)
    recipe_id = Column(String(36), ForeignKey("recipes.id"), nullable=True)
    custom_title = Column(String(255), nullable=True)
    status = Column(String(50), default="planned")
    visibility = Column(String(50), default="private")
    planned_total_quantity = Column(Float, nullable=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    
    meal_plan = relationship("MealPlan", back_populates="planned_meals")
    participants = relationship("MealParticipant", back_populates="planned_meal", cascade="all, delete-orphan")
    prepared_batch = relationship("PreparedMealBatch", back_populates="planned_meal", uselist=False, cascade="all, delete-orphan")

class MealParticipant(Base):
    __tablename__ = "meal_participants"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    planned_meal_id = Column(String(36), ForeignKey("planned_meals.id"), nullable=False)
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    target_calories = Column(Float, nullable=True)
    target_share_ratio = Column(Float, nullable=True)
    target_portion_g = Column(Float, nullable=True)
    actual_portion_g = Column(Float, nullable=True)
    participation_status = Column(String(50), default=ParticipationStatus.PLANNED)
    
    planned_meal = relationship("PlannedMeal", back_populates="participants")

class PreparedMealBatch(Base):
    __tablename__ = "prepared_meal_batches"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    planned_meal_id = Column(String(36), ForeignKey("planned_meals.id"), nullable=False)
    finished_weight_g = Column(Float, nullable=False)
    prepared_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    notes = Column(Text, nullable=True)
    
    planned_meal = relationship("PlannedMeal", back_populates="prepared_batch")
    allocations = relationship("PreparedMealAllocation", back_populates="batch", cascade="all, delete-orphan")

class PreparedMealAllocation(Base):
    __tablename__ = "prepared_meal_allocations"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    prepared_meal_batch_id = Column(String(36), ForeignKey("prepared_meal_batches.id"), nullable=False)
    user_id = Column(String(36), ForeignKey("users.id"), nullable=True)
    allocation_type = Column(String(50), nullable=False)  # 'participant', 'leftover', 'meal_prep'
    weight_g = Column(Float, nullable=False)
    calories = Column(Float, nullable=True)
    
    batch = relationship("PreparedMealBatch", back_populates="allocations")

class ShoppingList(Base):
    __tablename__ = "shopping_lists"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    owner_type = Column(String(50), nullable=False)  # 'user' or 'space'
    owner_user_id = Column(String(36), ForeignKey("users.id"), nullable=True)
    owner_space_id = Column(String(36), ForeignKey("spaces.id"), nullable=True)
    name = Column(String(255), nullable=False)
    status = Column(String(50), default="active")
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    
    space = relationship("Space", back_populates="shopping_lists")
    items = relationship("ShoppingListItem", back_populates="shopping_list", cascade="all, delete-orphan")

class ShoppingListItem(Base):
    __tablename__ = "shopping_list_items"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    shopping_list_id = Column(String(36), ForeignKey("shopping_lists.id"), nullable=False)
    source_recipe_id = Column(String(36), ForeignKey("recipes.id"), nullable=True)
    name = Column(String(255), nullable=False)
    quantity = Column(Float, nullable=True)
    unit = Column(String(50), nullable=True)
    category = Column(String(100), nullable=True)
    checked = Column(Boolean, default=False)
    manually_added = Column(Boolean, default=True)
    sort_order = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    
    shopping_list = relationship("ShoppingList", back_populates="items")

class WeightEntry(Base):
    __tablename__ = "weight_entries"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    measured_at = Column(DateTime(timezone=True), nullable=False)
    weight_kg = Column(Float, nullable=False)
    source = Column(String(50), default="manual")
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    
    user = relationship("User", back_populates="weight_entries")

class StepEntry(Base):
    __tablename__ = "step_entries"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    date = Column(DateTime(timezone=True), nullable=False)
    steps = Column(Integer, nullable=False)
    source = Column(String(50), default="manual")
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    
    user = relationship("User", back_populates="step_entries")

class NutritionGoal(Base):
    __tablename__ = "nutrition_goals"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    valid_from = Column(DateTime(timezone=True), nullable=False)
    valid_to = Column(DateTime(timezone=True), nullable=True)
    goal_type = Column(String(50), nullable=False)
    daily_calorie_target = Column(Float, nullable=True)
    daily_protein_target_g = Column(Float, nullable=True)
    daily_fat_target_g = Column(Float, nullable=True)
    daily_carbohydrate_target_g = Column(Float, nullable=True)
    source = Column(String(50), default="manual")
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    
    user = relationship("User", back_populates="nutrition_goals")

class ActivityGoal(Base):
    __tablename__ = "activity_goals"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    valid_from = Column(DateTime(timezone=True), nullable=False)
    valid_to = Column(DateTime(timezone=True), nullable=True)
    daily_step_target = Column(Integer, nullable=True)
    weekly_workout_target = Column(Integer, nullable=True)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    
    user = relationship("User", back_populates="activity_goals")

class TrainingSession(Base):
    __tablename__ = "training_sessions"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    space_id = Column(String(36), ForeignKey("spaces.id"), nullable=True)
    created_by_user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    date = Column(DateTime(timezone=True), nullable=False)
    session_type = Column(String(50), nullable=False)
    title = Column(String(255), nullable=False)
    target_duration_minutes = Column(Integer, nullable=True)
    target_steps = Column(Integer, nullable=True)
    notes = Column(Text, nullable=True)
    visibility = Column(String(50), default="private")
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)
    
    user = relationship("User", back_populates="training_sessions", foreign_keys="TrainingSession.user_id")
    participants = relationship("TrainingParticipant", back_populates="training_session", cascade="all, delete-orphan")

class TrainingParticipant(Base):
    __tablename__ = "training_participants"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    training_session_id = Column(String(36), ForeignKey("training_sessions.id"), nullable=False)
    user_id = Column(String(36), ForeignKey("users.id"), nullable=False)
    completion_status = Column(String(50), default=CompletionStatus.PLANNED)
    actual_duration_minutes = Column(Integer, nullable=True)
    actual_steps = Column(Integer, nullable=True)
    notes = Column(Text, nullable=True)
    
    training_session = relationship("TrainingSession", back_populates="participants")