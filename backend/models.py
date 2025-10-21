from database import db
from werkzeug.security import generate_password_hash, check_password_hash
import json

class Family(db.Model):
    __tablename__ = 'families'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False, unique=True)
    users = db.relationship('User', backref='family', lazy=True)
    tasks = db.relationship('Task', backref='family', lazy=True)
    grocery_items = db.relationship('GroceryItem', backref='family', lazy=True)
    meals = db.relationship('Meal', backref='family', lazy=True)
    recipes = db.relationship('Recipe', backref='family', lazy=True)
    thoughts = db.relationship('Thought', backref='family', lazy=True)

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name
        }

class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)
    email = db.Column(db.String(120), nullable=False)
    is_accepted = db.Column(db.Boolean, default=False, nullable=False)
    family_id = db.Column(db.Integer, db.ForeignKey('families.id'), nullable=False)
    tasks = db.relationship('Task', backref='user', lazy=True)
    thoughts = db.relationship('Thought', backref='user', lazy=True)

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

    def to_dict(self):
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'is_accepted': self.is_accepted,
            'family_id': self.family_id
        }

class Task(db.Model):
    __tablename__ = 'tasks'
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text, nullable=True)
    completed = db.Column(db.Boolean, default=False, nullable=False)
    family_id = db.Column(db.Integer, db.ForeignKey('families.id'), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=True)

    def to_dict(self):
        return {
            'id': self.id,
            'title': self.title,
            'description': self.description,
            'completed': self.completed,
            'family_id': self.family_id,
            'user_id': self.user_id
        }

class GroceryItem(db.Model):
    __tablename__ = 'grocery_items'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    quantity = db.Column(db.String(50), nullable=True)
    category = db.Column(db.String(50), default='Other', nullable=False)
    is_completed = db.Column(db.Boolean, default=False, nullable=False)
    family_id = db.Column(db.Integer, db.ForeignKey('families.id'), nullable=False)

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'quantity': self.quantity,
            'category': self.category,
            'is_completed': self.is_completed,
            'family_id': self.family_id
        }

class Meal(db.Model):
    __tablename__ = 'meals'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    date = db.Column(db.String(20), nullable=True)
    recipe_id = db.Column(db.Integer, db.ForeignKey('recipes.id'), nullable=True)
    meal_time = db.Column(db.String(20), nullable=True)
    family_id = db.Column(db.Integer, db.ForeignKey('families.id'), nullable=False)

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'date': self.date,
            'recipe_id': self.recipe_id,
            'meal_time': self.meal_time,
            'family_id': self.family_id
        }

class Recipe(db.Model):
    __tablename__ = 'recipes'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    instructions = db.Column(db.Text, nullable=True)  # JSON-encoded list of strings
    family_id = db.Column(db.Integer, db.ForeignKey('families.id'), nullable=False)
    ingredients = db.relationship('RecipeIngredient', backref='recipe', lazy=True, cascade="all, delete-orphan")
    meals = db.relationship('Meal', backref='recipe', lazy=True)

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'instructions': json.loads(self.instructions) if self.instructions else [],
            'family_id': self.family_id,
            'ingredients': [ingredient.to_dict() for ingredient in self.ingredients]
        }

class RecipeIngredient(db.Model):
    __tablename__ = 'recipe_ingredients'
    id = db.Column(db.Integer, primary_key=True)
    recipe_id = db.Column(db.Integer, db.ForeignKey('recipes.id'), nullable=False)
    name = db.Column(db.String(100), nullable=False)
    quantity = db.Column(db.String(50), nullable=True)

    def to_dict(self):
        return {
            'id': self.id,
            'recipe_id': self.recipe_id,
            'name': self.name,
            'quantity': self.quantity
        }

class Thought(db.Model):
    __tablename__ = 'thoughts'
    id = db.Column(db.Integer, primary_key=True)
    content = db.Column(db.Text, nullable=False)
    timestamp = db.Column(db.DateTime, server_default=db.func.now())
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    family_id = db.Column(db.Integer, db.ForeignKey('families.id'), nullable=False)

    def to_dict(self):
        return {
            'id': self.id,
            'content': self.content,
            'timestamp': self.timestamp.isoformat(),
            'user_id': self.user_id,
            'family_id': self.family_id,
            'user': self.user.to_dict()
        }
