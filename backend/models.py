from sqlalchemy import create_engine, Column, Integer, String, Boolean, ForeignKey, Text
from sqlalchemy.orm import sessionmaker, relationship
from sqlalchemy.ext.declarative import declarative_base
from werkzeug.security import generate_password_hash, check_password_hash
from database import Base
import json

class Family(Base):
    __tablename__ = 'families'
    id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)
    users = relationship('User', back_populates='family')
    tasks = relationship('Task', back_populates='family')
    grocery_items = relationship('GroceryItem', back_populates='family')
    meals = relationship('Meal', back_populates='family')
    recipes = relationship('Recipe', back_populates='family')

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name
        }

class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True)
    username = Column(String(80), unique=True, nullable=False)
    password_hash = Column(String(128))
    family_id = Column(Integer, ForeignKey('families.id'), nullable=False)
    family = relationship('Family', back_populates='users')
    tasks = relationship('Task', back_populates='user')

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

    def to_dict(self):
        return {
            'id': self.id,
            'username': self.username,
            'family_id': self.family_id
        }

class Task(Base):
    __tablename__ = 'tasks'
    id = Column(Integer, primary_key=True)
    title = Column(String(120), nullable=False)
    description = Column(Text)
    completed = Column(Boolean, default=False)
    family_id = Column(Integer, ForeignKey('families.id'), nullable=False)
    user_id = Column(Integer, ForeignKey('users.id'))
    family = relationship('Family', back_populates='tasks')
    user = relationship('User', back_populates='tasks')

    def to_dict(self):
        return {
            'id': self.id,
            'title': self.title,
            'description': self.description,
            'completed': self.completed,
            'family_id': self.family_id,
            'user_id': self.user_id
        }

class GroceryItem(Base):
    __tablename__ = 'grocery_items'
    id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)
    quantity = Column(String(50))
    category = Column(String(50), default='Other')
    is_completed = Column(Boolean, default=False)
    family_id = Column(Integer, ForeignKey('families.id'), nullable=False)
    family = relationship('Family', back_populates='grocery_items')

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'quantity': self.quantity,
            'category': self.category,
            'is_completed': self.is_completed,
            'family_id': self.family_id
        }

class Meal(Base):
    __tablename__ = 'meals'
    id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)
    date = Column(String(20))
    recipe_id = Column(Integer, ForeignKey('recipes.id'))
    meal_time = Column(String(20))
    family_id = Column(Integer, ForeignKey('families.id'), nullable=False)
    family = relationship('Family', back_populates='meals')
    recipe = relationship('Recipe')

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'date': self.date,
            'recipe_id': self.recipe_id,
            'meal_time': self.meal_time,
            'family_id': self.family_id
        }

class Recipe(Base):
    __tablename__ = 'recipes'
    id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)
    instructions = Column(Text)
    family_id = Column(Integer, ForeignKey('families.id'), nullable=False)
    family = relationship('Family', back_populates='recipes')
    ingredients = relationship('RecipeIngredient', back_populates='recipe', cascade="all, delete-orphan")

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'instructions': json.loads(self.instructions) if self.instructions else [],
            'family_id': self.family_id,
            'ingredients': [ingredient.to_dict() for ingredient in self.ingredients]
        }

class RecipeIngredient(Base):
    __tablename__ = 'recipe_ingredients'
    id = Column(Integer, primary_key=True)
    recipe_id = Column(Integer, ForeignKey('recipes.id'), nullable=False)
    name = Column(String(100), nullable=False)
    quantity = Column(String(50))
    recipe = relationship('Recipe', back_populates='ingredients')

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'quantity': self.quantity
        }
