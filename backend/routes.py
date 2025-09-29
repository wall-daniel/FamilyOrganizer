from flask import Blueprint, request, jsonify
from backend.models import Task, Meal, Recipe

bp = Blueprint('api', __name__, url_prefix='/api')

# --- Task Endpoints ---
@bp.route('/tasks', methods=['GET'])
def get_tasks():
    tasks = Task.all()
    return jsonify(tasks)

@bp.route('/tasks', methods=['POST'])
def add_task():
    new_task_data = request.json
    if not new_task_data or 'title' not in new_task_data:
        return jsonify({"error": "Title is required"}), 400
    
    task = Task.create(
        title=new_task_data['title'],
        description=new_task_data.get('description', ''),
        completed=new_task_data.get('completed', False)
    )
    return jsonify(task), 201

@bp.route('/tasks/<int:task_id>', methods=['GET'])
def get_task(task_id):
    task = Task.get(task_id)
    if task:
        return jsonify(task)
    return jsonify({"error": "Task not found"}), 404

@bp.route('/tasks/<int:task_id>', methods=['PUT'])
def update_task(task_id):
    updated_data = request.json
    row_count = Task.update(
        task_id,
        title=updated_data.get('title'),
        description=updated_data.get('description'),
        completed=updated_data.get('completed')
    )
    if row_count == 0:
        return jsonify({"error": "Task not found"}), 404
    return jsonify({"message": "Task updated successfully"})

@bp.route('/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    row_count = Task.delete(task_id)
    if row_count == 0:
        return jsonify({"error": "Task not found"}), 404
    return jsonify({"message": "Task deleted successfully"})

# --- Meal Endpoints ---
@bp.route('/meals', methods=['GET'])
def get_meals():
    meals = Meal.all()
    return jsonify(meals)

@bp.route('/meals', methods=['POST'])
def add_meal():
    new_meal_data = request.json
    if not new_meal_data or 'name' not in new_meal_data:
        return jsonify({"error": "Meal name is required"}), 400
    
    meal = Meal.create(
        name=new_meal_data['name'],
        date=new_meal_data.get('date', ''),
        recipe_id=new_meal_data.get('recipe_id')
    )
    return jsonify(meal), 201

@bp.route('/meals/<int:meal_id>', methods=['GET'])
def get_meal(meal_id):
    meal = Meal.get(meal_id)
    if meal:
        return jsonify(meal)
    return jsonify({"error": "Meal not found"}), 404

@bp.route('/meals/<int:meal_id>', methods=['PUT'])
def update_meal(meal_id):
    updated_data = request.json
    row_count = Meal.update(
        meal_id,
        name=updated_data.get('name'),
        date=updated_data.get('date'),
        recipe_id=updated_data.get('recipe_id')
    )
    if row_count == 0:
        return jsonify({"error": "Meal not found"}), 404
    return jsonify({"message": "Meal updated successfully"})

@bp.route('/meals/<int:meal_id>', methods=['DELETE'])
def delete_meal(meal_id):
    row_count = Meal.delete(meal_id)
    if row_count == 0:
        return jsonify({"error": "Meal not found"}), 404
    return jsonify({"message": "Meal deleted successfully"})

# --- Recipe Endpoints ---
@bp.route('/recipes', methods=['GET'])
def get_recipes():
    recipes = Recipe.all()
    return jsonify(recipes)

@bp.route('/recipes', methods=['POST'])
def add_recipe():
    new_recipe_data = request.json
    if not new_recipe_data or 'name' not in new_recipe_data:
        return jsonify({"error": "Recipe name is required"}), 400
    
    recipe = Recipe.create(
        name=new_recipe_data['name'],
        ingredients=new_recipe_data.get('ingredients', ''),
        instructions=new_recipe_data.get('instructions', '')
    )
    return jsonify(recipe), 201

@bp.route('/recipes/<int:recipe_id>', methods=['GET'])
def get_recipe(recipe_id):
    recipe = Recipe.get(recipe_id)
    if recipe:
        return jsonify(recipe)
    return jsonify({"error": "Recipe not found"}), 404

@bp.route('/recipes/<int:recipe_id>', methods=['PUT'])
def update_recipe(recipe_id):
    updated_data = request.json
    row_count = Recipe.update(
        recipe_id,
        name=updated_data.get('name'),
        ingredients=updated_data.get('ingredients'),
        instructions=updated_data.get('instructions')
    )
    if row_count == 0:
        return jsonify({"error": "Recipe not found"}), 404
    return jsonify({"message": "Recipe updated successfully"})

@bp.route('/recipes/<int:recipe_id>', methods=['DELETE'])
def delete_recipe(recipe_id):
    row_count = Recipe.delete(recipe_id)
    if row_count == 0:
        return jsonify({"error": "Recipe not found"}), 404
    return jsonify({"message": "Recipe deleted successfully"})
