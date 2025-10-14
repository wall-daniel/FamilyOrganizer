from flask import Blueprint, request, jsonify, g, current_app
from models import Task, Meal, Recipe, GroceryItem, User, Family
from database import get_db, row_to_dict
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

    if User.get_by_username(username):
        return jsonify({'message': 'Username already exists'}), 400

    family = Family.get_by_name(family_name)
    if not family:
        family = Family.create(name=family_name)
        family_id = family['id']
    else:
        family_id = family['id']

    new_user = User()
    new_user.set_password(password)
    user_data = User.create(username=username, password_hash=new_user.password_hash, family_id=family_id)

    return jsonify({'message': 'New user created!'}), 201

@bp.route('/login', methods=['POST'])
def login():
    auth = request.authorization

    if not auth or not auth.username or not auth.password:
        return jsonify({'message': 'Could not verify'}), 401

    user = User.get_by_username(auth.username)

    if not user or not User().check_password(user['password_hash'], auth.password):
        return jsonify({'message': 'Could not verify'}), 401

    token = jwt.encode({
        'id': user['id'],
        'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=24)
    }, current_app.config['SECRET_KEY'], algorithm="HS256")

    return jsonify({'token': token})

# --- Task Endpoints ---
@bp.route('/tasks', methods=['GET'])
@token_required
def get_tasks():
    tasks = Task.all(g.current_user['family_id'])
    return jsonify(tasks)

@bp.route('/tasks', methods=['POST'])
@token_required
def add_task():
    new_task_data = request.json
    if not new_task_data or 'title' not in new_task_data:
        return jsonify({"error": "Title is required"}), 400
    
    task = Task.create(
        title=new_task_data['title'],
        description=new_task_data.get('description', ''),
        completed=new_task_data.get('completed', False),
        family_id=g.current_user['family_id'],
        user_id=g.current_user['id']
    )
    return jsonify(task), 201

@bp.route('/tasks/<int:task_id>', methods=['GET'])
@token_required
def get_task(task_id):
    task = Task.get(task_id, g.current_user['family_id'])
    if task:
        return jsonify(task)
    return jsonify({"error": "Task not found"}), 404

@bp.route('/tasks/<int:task_id>', methods=['PUT'])
@token_required
def update_task(task_id):
    updated_data = request.json
    row_count = Task.update(
        task_id,
        g.current_user['family_id'],
        title=updated_data.get('title'),
        description=updated_data.get('description'),
        completed=updated_data.get('completed')
    )
    if row_count == 0:
        return jsonify({"error": "Task not found"}), 404
    return jsonify({"message": "Task updated successfully"})

@bp.route('/tasks/<int:task_id>', methods=['DELETE'])
@token_required
def delete_task(task_id):
    row_count = Task.delete(task_id, g.current_user['family_id'])
    if row_count == 0:
        return jsonify({"error": "Task not found"}), 404
    return jsonify({"message": "Task deleted successfully"})

# --- Meal Endpoints ---
@bp.route('/meals', methods=['GET'])
@token_required
def get_meals():
    meals = Meal.all(g.current_user['family_id'])
    return jsonify(meals)

@bp.route('/meals', methods=['POST'])
@token_required
def add_meal():
    new_meal_data = request.json
    if not new_meal_data or 'name' not in new_meal_data:
        return jsonify({"error": "Meal name is required"}), 400
    
    meal = Meal.create(
        name=new_meal_data['name'],
        date=new_meal_data.get('date', ''),
        recipe_id=new_meal_data.get('recipe_id'),
        meal_time=new_meal_data.get('meal_time'),
        family_id=g.current_user['family_id']
    )
    return jsonify(meal), 201

@bp.route('/meals/<int:meal_id>', methods=['GET'])
@token_required
def get_meal(meal_id):
    meal = Meal.get(meal_id, g.current_user['family_id'])
    if meal:
        return jsonify(meal)
    return jsonify({"error": "Meal not found"}), 404

@bp.route('/meals/<int:meal_id>', methods=['PUT'])
@token_required
def update_meal(meal_id):
    updated_data = request.json
    row_count = Meal.update(
        meal_id,
        g.current_user['family_id'],
        name=updated_data.get('name'),
        date=updated_data.get('date'),
        recipe_id=updated_data.get('recipe_id'),
        meal_time=updated_data.get('meal_time')
    )
    if row_count == 0:
        return jsonify({"error": "Meal not found"}), 404
    return jsonify({"message": "Meal updated successfully"})

@bp.route('/meals/<int:meal_id>', methods=['DELETE'])
@token_required
def delete_meal(meal_id):
    row_count = Meal.delete(meal_id, g.current_user['family_id'])
    if row_count == 0:
        return jsonify({"error": "Meal not found"}), 404
    return jsonify({"message": "Meal deleted successfully"})

# --- Recipe Endpoints ---
@bp.route('/recipes', methods=['GET'])
@token_required
def get_recipes():
    recipes = Recipe.all(g.current_user['family_id'])
    return jsonify(recipes)

@bp.route('/recipes', methods=['POST'])
@token_required
def add_recipe():
    new_recipe_data = request.json
    if not new_recipe_data or 'name' not in new_recipe_data:
        return jsonify({"error": "Recipe name is required"}), 400
    
    recipe = Recipe.create(
        name=new_recipe_data['name'],
        ingredients=new_recipe_data.get('ingredients', []),
        instructions=new_recipe_data.get('instructions', []),
        family_id=g.current_user['family_id']
    )
    return jsonify(recipe), 201

@bp.route('/recipes/<int:recipe_id>', methods=['GET'])
@token_required
def get_recipe(recipe_id):
    recipe = Recipe.get(recipe_id, g.current_user['family_id'])
    if recipe:
        return jsonify(recipe)
    return jsonify({"error": "Recipe not found"}), 404

@bp.route('/recipes/<int:recipe_id>', methods=['PUT'])
@token_required
def update_recipe(recipe_id):
    updated_data = request.json
    row_count = Recipe.update(
        recipe_id,
        g.current_user['family_id'],
        name=updated_data.get('name'),
        ingredients=updated_data.get('ingredients'),
        instructions=updated_data.get('instructions')
    )
    if row_count == 0:
        return jsonify({"error": "Recipe not found"}), 404
    return jsonify({"message": "Recipe updated successfully"})

@bp.route('/recipes/<int:recipe_id>', methods=['DELETE'])
@token_required
def delete_recipe(recipe_id):
    row_count = Recipe.delete(recipe_id, g.current_user['family_id'])
    if row_count == 0:
        return jsonify({"error": "Recipe not found"}), 404
    return jsonify({"message": "Recipe deleted successfully"})

# --- Grocery Item Endpoints ---
@bp.route('/grocery_items', methods=['GET'])
@token_required
def get_grocery_items():
    items = GroceryItem.all(g.current_user['family_id'])
    return jsonify(items)

@bp.route('/grocery_items', methods=['POST'])
@token_required
def add_grocery_item():
    from models import parse_quantity_and_unit
    
    new_item_data = request.json
    if not new_item_data or 'name' not in new_item_data:
        return jsonify({"error": "Name is required"}), 400
    
    name = new_item_data['name']
    quantity_str = new_item_data.get('quantity', '')
    category = new_item_data.get('category', 'Other')
    is_completed = new_item_data.get('is_completed', False)
    
    # Parse quantity and unit from the incoming item
    new_value, new_unit = parse_quantity_and_unit(quantity_str)
    
    # Check if an existing item with the same name and unit exists
    existing_item = GroceryItem.find_by_name_and_unit(name, new_unit, g.current_user['family_id'])
    
    if existing_item:
        # Parse the existing item's quantity
        existing_value, _ = parse_quantity_and_unit(existing_item['quantity'])
        
        # Combine quantities
        combined_value = existing_value + new_value
        
        # Format the new quantity string
        if new_unit:
            new_quantity = f"{combined_value} {new_unit}"
        else:
            new_quantity = str(combined_value) if combined_value != 0 else ''
        
        # Update the existing item
        GroceryItem.update(
            existing_item['id'],
            g.current_user['family_id'],
            quantity=new_quantity
        )
        
        # Return the updated item
        updated_item = GroceryItem.get(existing_item['id'], g.current_user['family_id'])
        return jsonify(updated_item), 200
    else:
        # No existing item found, create a new one
        item = GroceryItem.create(
            name=name,
            quantity=quantity_str,
            category=category,
            is_completed=is_completed,
            family_id=g.current_user['family_id']
        )
        return jsonify(item), 201

@bp.route('/grocery_items/<int:item_id>', methods=['GET'])
@token_required
def get_grocery_item(item_id):
    item = GroceryItem.get(item_id, g.current_user['family_id'])
    if item:
        return jsonify(item)
    return jsonify({"error": "Grocery item not found"}), 404

@bp.route('/grocery_items/<int:item_id>', methods=['PUT'])
@token_required
def update_grocery_item(item_id):
    updated_data = request.json
    row_count = GroceryItem.update(
        item_id,
        g.current_user['family_id'],
        name=updated_data.get('name'),
        quantity=updated_data.get('quantity'),
        category=updated_data.get('category'),
        is_completed=updated_data.get('is_completed')
    )
    if row_count == 0:
        return jsonify({"error": "Grocery item not found"}), 404
    return jsonify({"message": "Grocery item updated successfully"})

@bp.route('/grocery_items/<int:item_id>', methods=['DELETE'])
@token_required
def delete_grocery_item(item_id):
    row_count = GroceryItem.delete(item_id, g.current_user['family_id'])
    if row_count == 0:
        return jsonify({"error": "Grocery item not found"}), 404
    return jsonify({"message": "Grocery item deleted successfully"})
