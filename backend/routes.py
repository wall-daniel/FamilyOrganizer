from flask import Blueprint, request, jsonify, g, current_app
from models import Task, Meal, Recipe, GroceryItem, User, Family, Thought, RecipeIngredient
from database import db
from auth import token_required
import jwt
import datetime
import json

bp = Blueprint('api', __name__, url_prefix='/api')

# --- Auth Endpoints ---
@bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    
    family_name = data.get('family_name')
    username = data.get('username')
    password = data.get('password')
    email = data.get('email')

    if not all([family_name, username, password, email]):
        return jsonify({'message': 'Missing family_name, username, password, or email'}), 400

    if User.query.filter_by(username=username).first():
        return jsonify({'message': 'Username already exists'}), 400

    family = Family.query.filter_by(name=family_name).first()
    is_accepted_status = False
    if not family:
        family = Family(name=family_name)
        db.session.add(family)
        db.session.flush()  # Flush to get the family id
        is_accepted_status = True # First user in a new family is automatically accepted
    
    new_user = User(username=username, email=email, family_id=family.id, is_accepted=is_accepted_status)
    new_user.set_password(password)
    db.session.add(new_user)
    db.session.commit()

    return jsonify(new_user.to_dict()), 201

@bp.route('/login', methods=['POST'])
def login():
    auth = request.get_json()

    if not auth or not auth.get('username') or not auth.get('password'):
        return jsonify({'message': 'Could not verify' + str(auth)}), 401

    user = User.query.filter_by(username=auth.get('username')).first()

    if not user or not user.check_password(auth.get('password')):
        return jsonify({'message': 'Could not verify'}), 401

    token = jwt.encode({
        'id': user.id,
        'is_accepted': user.is_accepted,
        'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=24)
    }, current_app.config['SECRET_KEY'], algorithm="HS256")

    return jsonify({'token': token})

@bp.route('/family/users', methods=['GET'])
@token_required
def get_family_users():
    users = User.query.filter_by(family_id=g.current_user.family_id).all()
    return jsonify([user.to_dict() for user in users])

@bp.route('/family/users/<int:user_id>/accept', methods=['PUT'])
@token_required
def accept_family_user(user_id):
    if not g.current_user.is_accepted:
        return jsonify({'message': 'Only accepted family members can accept new users.'}), 403

    target_user = User.query.get(user_id)
    if not target_user or target_user.family_id != g.current_user.family_id:
        return jsonify({'message': 'User not found in your family.'}), 404

    if target_user.is_accepted:
        return jsonify({'message': 'User is already accepted.'}), 400

    target_user.is_accepted = True
    db.session.commit()
    
    return jsonify({'message': 'User accepted successfully!'}), 200

# --- Task Endpoints ---
@bp.route('/tasks', methods=['GET'])
@token_required
def get_tasks():
    tasks = Task.query.filter_by(family_id=g.current_user.family_id).all()
    return jsonify([task.to_dict() for task in tasks])

@bp.route('/tasks', methods=['POST'])
@token_required
def add_task():
    if not g.current_user.is_accepted:
        return jsonify({'message': 'You must be an accepted family member to add tasks.'}), 403
    new_task_data = request.json
    if not new_task_data or 'title' not in new_task_data:
        return jsonify({"error": "Title is required"}), 400
    
    task = Task(
        title=new_task_data['title'],
        description=new_task_data.get('description', ''),
        completed=new_task_data.get('completed', False),
        due_date=datetime.datetime.fromisoformat(new_task_data['due_date']) if new_task_data.get('due_date') else None,
        family_id=g.current_user.family_id,
        author_id=g.current_user.id,
        assigned_user_id=new_task_data.get('assigned_user_id')
    )
    db.session.add(task)
    db.session.commit()
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
    if not g.current_user.is_accepted:
        return jsonify({'message': 'You must be an accepted family member to update tasks.'}), 403
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
    if 'due_date' in updated_data:
        task.due_date = datetime.datetime.fromisoformat(updated_data['due_date']) if updated_data.get('due_date') else None
    if 'assigned_user_id' in updated_data:
        task.assigned_user_id = updated_data['assigned_user_id']
    
    db.session.commit()
    return jsonify(task.to_dict())

@bp.route('/tasks/<int:task_id>', methods=['DELETE'])
@token_required
def delete_task(task_id):
    if not g.current_user.is_accepted:
        return jsonify({'message': 'You must be an accepted family member to delete tasks.'}), 403
    task = Task.query.filter_by(id=task_id, family_id=g.current_user.family_id).first()
    if not task:
        return jsonify({"error": "Task not found"}), 404
    
    db.session.delete(task)
    db.session.commit()
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
    if not g.current_user.is_accepted:
        return jsonify({'message': 'You must be an accepted family member to add meals.'}), 403
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
    db.session.add(meal)
    db.session.commit()
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
    if not g.current_user.is_accepted:
        return jsonify({'message': 'You must be an accepted family member to update meals.'}), 403
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
        
    db.session.commit()
    return jsonify(meal.to_dict())

@bp.route('/meals/<int:meal_id>', methods=['DELETE'])
@token_required
def delete_meal(meal_id):
    if not g.current_user.is_accepted:
        return jsonify({'message': 'You must be an accepted family member to delete meals.'}), 403
    meal = Meal.query.filter_by(id=meal_id, family_id=g.current_user.family_id).first()
    if not meal:
        return jsonify({"error": "Meal not found"}), 404
        
    db.session.delete(meal)
    db.session.commit()
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
    if not g.current_user.is_accepted:
        return jsonify({'message': 'You must be an accepted family member to add recipes.'}), 403
    new_recipe_data = request.json
    if not new_recipe_data or 'name' not in new_recipe_data:
        return jsonify({"error": "Recipe name is required"}), 400
    
    recipe = Recipe(
        name=new_recipe_data['name'],
        instructions=json.dumps(new_recipe_data.get('instructions', [])),
        family_id=g.current_user.family_id
    )

    if 'ingredients' in new_recipe_data:
        for ing_data in new_recipe_data['ingredients']:
            ingredient = RecipeIngredient(
                name=ing_data['name'],
                quantity=ing_data.get('quantity')
            )
            recipe.ingredients.append(ingredient)

    db.session.add(recipe)
    db.session.commit()
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
    if not g.current_user.is_accepted:
        return jsonify({'message': 'You must be an accepted family member to update recipes.'}), 403
    
    recipe = Recipe.query.filter_by(id=recipe_id, family_id=g.current_user.family_id).first()
    if not recipe:
        return jsonify({"error": "Recipe not found"}), 404

    updated_data = request.json
    if 'name' in updated_data:
        recipe.name = updated_data['name']
    if 'instructions' in updated_data:
        recipe.instructions = json.dumps(updated_data['instructions'])
    
    if 'ingredients' in updated_data:
        # Clear existing ingredients and add new ones
        recipe.ingredients.clear()
        for ing_data in updated_data['ingredients']:
            ingredient = RecipeIngredient(
                name=ing_data['name'],
                quantity=ing_data.get('quantity')
            )
            recipe.ingredients.append(ingredient)

    db.session.commit()
    return jsonify(recipe.to_dict())

@bp.route('/recipes/<int:recipe_id>', methods=['DELETE'])
@token_required
def delete_recipe(recipe_id):
    if not g.current_user.is_accepted:
        return jsonify({'message': 'You must be an accepted family member to delete recipes.'}), 403
    recipe = Recipe.query.filter_by(id=recipe_id, family_id=g.current_user.family_id).first()
    if not recipe:
        return jsonify({"error": "Recipe not found"}), 404
        
    db.session.delete(recipe)
    db.session.commit()
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
    if not g.current_user.is_accepted:
        return jsonify({'message': 'You must be an accepted family member to add grocery items.'}), 403
    
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
    db.session.add(item)
    db.session.commit()
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
    if not g.current_user.is_accepted:
        return jsonify({'message': 'You must be an accepted family member to update grocery items.'}), 403
    
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
        
    db.session.commit()
    return jsonify(item.to_dict())

@bp.route('/grocery_items/<int:item_id>', methods=['DELETE'])
@token_required
def delete_grocery_item(item_id):
    if not g.current_user.is_accepted:
        return jsonify({'message': 'You must be an accepted family member to delete grocery items.'}), 403
    item = GroceryItem.query.filter_by(id=item_id, family_id=g.current_user.family_id).first()
    if not item:
        return jsonify({"error": "Grocery item not found"}), 404
        
    db.session.delete(item)
    db.session.commit()
    return jsonify({"message": "Grocery item deleted successfully"})

# --- Thought Endpoints ---
@bp.route('/thoughts', methods=['POST'])
@token_required
def add_thought():
    if not g.current_user.is_accepted:
        return jsonify({'message': 'You must be an accepted family member to post thoughts.'}), 403
    new_thought_data = request.json
    if not new_thought_data or 'content' not in new_thought_data:
        return jsonify({"error": "Content is required"}), 400
    
    thought = Thought(
        content=new_thought_data['content'],
        user_id=g.current_user.id,
        family_id=g.current_user.family_id
    )
    db.session.add(thought)
    db.session.commit()
    return jsonify(thought.to_dict()), 201

@bp.route('/thoughts', methods=['GET'])
@token_required
def get_thoughts():
    page = request.args.get('page', 1, type=int)
    limit = request.args.get('limit', 10, type=int)
    thoughts = Thought.query.filter_by(family_id=g.current_user.family_id).order_by(Thought.timestamp.desc()).paginate(page=page, per_page=limit, error_out=False)
    return jsonify([thought.to_dict() for thought in thoughts.items])
