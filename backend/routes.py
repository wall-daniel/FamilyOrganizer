from flask import Blueprint, request, jsonify, g, current_app
from models import Task, Meal, Recipe, GroceryItem, User, Family
from database import db_session
from auth import token_required
import jwt
import datetime

bp = Blueprint('api', __name__, url_prefix='/api')

# --- Auth Endpoints ---
@bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    
    family_name = data.get('family_name')
    username = data.get('username')
    password = data.get('password')

    if not all([family_name, username, password]):
        return jsonify({'message': 'Missing family_name, username, or password'}), 400

    if User.query.filter_by(username=username).first():
        return jsonify({'message': 'Username already exists'}), 400

    family = Family.query.filter_by(name=family_name).first()
    if not family:
        family = Family(name=family_name)
        db_session.add(family)
        db_session.commit()

    new_user = User(username=username, family_id=family.id)
    new_user.set_password(password)
    db_session.add(new_user)
    db_session.commit()

    return jsonify({'message': 'New user created!'}), 201

@bp.route('/login', methods=['POST'])
def login():
    auth = request.authorization

    if not auth or not auth.username or not auth.password:
        return jsonify({'message': 'Could not verify'}), 401

    user = User.query.filter_by(username=auth.username).first()

    if not user or not user.check_password(auth.password):
        return jsonify({'message': 'Could not verify'}), 401

    token = jwt.encode({
        'id': user.id,
        'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=24)
    }, current_app.config['SECRET_KEY'], algorithm="HS256")

    return jsonify({'token': token})

# --- Task Endpoints ---
@bp.route('/tasks', methods=['GET'])
@token_required
def get_tasks():
    tasks = Task.query.filter_by(family_id=g.current_user.family_id).all()
    return jsonify([task.to_dict() for task in tasks])

@bp.route('/tasks', methods=['POST'])
@token_required
def add_task():
    new_task_data = request.json
    if not new_task_data or 'title' not in new_task_data:
        return jsonify({"error": "Title is required"}), 400
    
    task = Task(
        title=new_task_data['title'],
        description=new_task_data.get('description', ''),
        completed=new_task_data.get('completed', False),
        family_id=g.current_user.family_id,
        user_id=g.current_user.id
    )
    db_session.add(task)
    db_session.commit()
    return jsonify(task.to_dict()), 201

@bp.route('/tasks/<int:task_id>', methods=['GET'])
@token_required
def get_task(task_id):
    task = Task.query.filter_by(id=task_id, family_id=g.current_user.family_id).first()
    if task:
        return jsonify(task.to_dict())
    return jsonify({"error": "Task not found"}), 404

@bp.route('/tasks/<int:task_id>', methods=['PUT'])
@token_required
def update_task(task_id):
    task = Task.query.filter_by(id=task_id, family_id=g.current_user.family_id).first()
    if not task:
        return jsonify({"error": "Task not found"}), 404
    
    updated_data = request.json
    if 'title' in updated_data:
        task.title = updated_data['title']
    if 'description' in updated_data:
        task.description = updated_data['description']
    if 'completed' in updated_data:
        task.completed = updated_data['completed']
    
    db_session.commit()
    return jsonify({"message": "Task updated successfully"})

@bp.route('/tasks/<int:task_id>', methods=['DELETE'])
@token_required
def delete_task(task_id):
    task = Task.query.filter_by(id=task_id, family_id=g.current_user.family_id).first()
    if not task:
        return jsonify({"error": "Task not found"}), 404
    
    db_session.delete(task)
    db_session.commit()
    return jsonify({"message": "Task deleted successfully"})

# --- Meal Endpoints ---
@bp.route('/meals', methods=['GET'])
@token_required
def get_meals():
    meals = Meal.query.filter_by(family_id=g.current_user.family_id).all()
    return jsonify([meal.to_dict() for meal in meals])

@bp.route('/meals', methods=['POST'])
@token_required
def add_meal():
    new_meal_data = request.json
    if not new_meal_data or 'name' not in new_meal_data:
        return jsonify({"error": "Meal name is required"}), 400
    
    meal = Meal(
        name=new_meal_data['name'],
        date=new_meal_data.get('date', ''),
        recipe_id=new_meal_data.get('recipe_id'),
        meal_time=new_meal_data.get('meal_time'),
        family_id=g.current_user.family_id
    )
    db_session.add(meal)
    db_session.commit()
    return jsonify(meal.to_dict()), 201

@bp.route('/meals/<int:meal_id>', methods=['GET'])
@token_required
def get_meal(meal_id):
    meal = Meal.query.filter_by(id=meal_id, family_id=g.current_user.family_id).first()
    if meal:
        return jsonify(meal.to_dict())
    return jsonify({"error": "Meal not found"}), 404

@bp.route('/meals/<int:meal_id>', methods=['PUT'])
@token_required
def update_meal(meal_id):
    meal = Meal.query.filter_by(id=meal_id, family_id=g.current_user.family_id).first()
    if not meal:
        return jsonify({"error": "Meal not found"}), 404
        
    updated_data = request.json
    if 'name' in updated_data:
        meal.name = updated_data['name']
    if 'date' in updated_data:
        meal.date = updated_data['date']
    if 'recipe_id' in updated_data:
        meal.recipe_id = updated_data['recipe_id']
    if 'meal_time' in updated_data:
        meal.meal_time = updated_data['meal_time']
        
    db_session.commit()
    return jsonify({"message": "Meal updated successfully"})

@bp.route('/meals/<int:meal_id>', methods=['DELETE'])
@token_required
def delete_meal(meal_id):
    meal = Meal.query.filter_by(id=meal_id, family_id=g.current_user.family_id).first()
    if not meal:
        return jsonify({"error": "Meal not found"}), 404
    
    db_session.delete(meal)
    db_session.commit()
    return jsonify({"message": "Meal deleted successfully"})

# --- Recipe Endpoints ---
@bp.route('/recipes', methods=['GET'])
@token_required
def get_recipes():
    recipes = Recipe.query.filter_by(family_id=g.current_user.family_id).all()
    return jsonify([recipe.to_dict() for recipe in recipes])

@bp.route('/recipes', methods=['POST'])
@token_required
def add_recipe():
    new_recipe_data = request.json
    if not new_recipe_data or 'name' not in new_recipe_data:
        return jsonify({"error": "Recipe name is required"}), 400
    
    recipe = Recipe(
        name=new_recipe_data['name'],
        instructions=new_recipe_data.get('instructions', []),
        family_id=g.current_user.family_id
    )
    db_session.add(recipe)
    db_session.commit()
    return jsonify(recipe.to_dict()), 201

@bp.route('/recipes/<int:recipe_id>', methods=['GET'])
@token_required
def get_recipe(recipe_id):
    recipe = Recipe.query.filter_by(id=recipe_id, family_id=g.current_user.family_id).first()
    if recipe:
        return jsonify(recipe.to_dict())
    return jsonify({"error": "Recipe not found"}), 404

@bp.route('/recipes/<int:recipe_id>', methods=['PUT'])
@token_required
def update_recipe(recipe_id):
    recipe = Recipe.query.filter_by(id=recipe_id, family_id=g.current_user.family_id).first()
    if not recipe:
        return jsonify({"error": "Recipe not found"}), 404
        
    updated_data = request.json
    if 'name' in updated_data:
        recipe.name = updated_data['name']
    if 'ingredients' in updated_data:
        recipe.ingredients = updated_data['ingredients']
    if 'instructions' in updated_data:
        recipe.instructions = updated_data['instructions']
        
    db_session.commit()
    return jsonify({"message": "Recipe updated successfully"})

@bp.route('/recipes/<int:recipe_id>', methods=['DELETE'])
@token_required
def delete_recipe(recipe_id):
    recipe = Recipe.query.filter_by(id=recipe_id, family_id=g.current_user.family_id).first()
    if not recipe:
        return jsonify({"error": "Recipe not found"}), 404
    
    db_session.delete(recipe)
    db_session.commit()
    return jsonify({"message": "Recipe deleted successfully"})

# --- Grocery Item Endpoints ---
@bp.route('/grocery_items', methods=['GET'])
@token_required
def get_grocery_items():
    items = GroceryItem.query.filter_by(family_id=g.current_user.family_id).all()
    return jsonify([item.to_dict() for item in items])

@bp.route('/grocery_items', methods=['POST'])
@token_required
def add_grocery_item():
    new_item_data = request.json
    if not new_item_data or 'name' not in new_item_data:
        return jsonify({"error": "Name is required"}), 400
    
    item = GroceryItem(
        name=new_item_data['name'],
        quantity=new_item_data.get('quantity', ''),
        category=new_item_data.get('category', 'Other'),
        is_completed=new_item_data.get('is_completed', False),
        family_id=g.current_user.family_id
    )
    db_session.add(item)
    db_session.commit()
    return jsonify(item.to_dict()), 201

@bp.route('/grocery_items/<int:item_id>', methods=['GET'])
@token_required
def get_grocery_item(item_id):
    item = GroceryItem.query.filter_by(id=item_id, family_id=g.current_user.family_id).first()
    if item:
        return jsonify(item.to_dict())
    return jsonify({"error": "Grocery item not found"}), 404

@bp.route('/grocery_items/<int:item_id>', methods=['PUT'])
@token_required
def update_grocery_item(item_id):
    item = GroceryItem.query.filter_by(id=item_id, family_id=g.current_user.family_id).first()
    if not item:
        return jsonify({"error": "Grocery item not found"}), 404
        
    updated_data = request.json
    if 'name' in updated_data:
        item.name = updated_data['name']
    if 'quantity' in updated_data:
        item.quantity = updated_data['quantity']
    if 'category' in updated_data:
        item.category = updated_data['category']
    if 'is_completed' in updated_data:
        item.is_completed = updated_data['is_completed']
        
    db_session.commit()
    return jsonify({"message": "Grocery item updated successfully"})

@bp.route('/grocery_items/<int:item_id>', methods=['DELETE'])
@token_required
def delete_grocery_item(item_id):
    item = GroceryItem.query.filter_by(id=item_id, family_id=g.current_user.family_id).first()
    if not item:
        return jsonify({"error": "Grocery item not found"}), 404
    
    db_session.delete(item)
    db_session.commit()
    return jsonify({"message": "Grocery item deleted successfully"})
