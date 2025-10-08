from database import get_db, row_to_dict
import json

class Task:
    def __init__(self, id=None, title=None, description=None, completed=False):
        self.id = id
        self.title = title
        self.description = description
        self.completed = completed

    @staticmethod
    def all():
        db = get_db()
        cursor = db.execute('SELECT * FROM tasks')
        return [row_to_dict(row) for row in cursor.fetchall()]

    @staticmethod
    def get(task_id):
        db = get_db()
        cursor = db.execute('SELECT * FROM tasks WHERE id = ?', (task_id,))
        task = cursor.fetchone()
        return row_to_dict(task) if task else None

    @staticmethod
    def create(title, description='', completed=False):
        db = get_db()
        cursor = db.execute('INSERT INTO tasks (title, description, completed) VALUES (?, ?, ?)',
                            (title, description, completed))
        db.commit()
        return {
            "id": cursor.lastrowid,
            "title": title,
            "description": description,
            "completed": completed
        }

    @staticmethod
    def update(task_id, title=None, description=None, completed=None):
        db = get_db()
        query_parts = []
        params = []
        if title is not None:
            query_parts.append('title = ?')
            params.append(title)
        if description is not None:
            query_parts.append('description = ?')
            params.append(description)
        if completed is not None:
            query_parts.append('completed = ?')
            params.append(completed)

        if not query_parts:
            return 0 # No fields to update

        query = 'UPDATE tasks SET ' + ', '.join(query_parts) + ' WHERE id = ?'
        params.append(task_id)
        cursor = db.execute(query, tuple(params))
        db.commit()
        return cursor.rowcount

    @staticmethod
    def delete(task_id):
        db = get_db()
        cursor = db.execute('DELETE FROM tasks WHERE id = ?', (task_id,))
        db.commit()
        return cursor.rowcount

class Meal:
    def __init__(self, id=None, name=None, date=None, recipe_id=None, meal_time=None):
        self.id = id
        self.name = name
        self.date = date
        self.recipe_id = recipe_id
        self.meal_time = meal_time

    @staticmethod
    def all():
        db = get_db()
        cursor = db.execute('SELECT * FROM meals')
        return [row_to_dict(row) for row in cursor.fetchall()]

    @staticmethod
    def get(meal_id):
        db = get_db()
        cursor = db.execute('SELECT * FROM meals WHERE id = ?', (meal_id,))
        meal = cursor.fetchone()
        return row_to_dict(meal) if meal else None

    @staticmethod
    def create(name, date='', recipe_id=None, meal_time=None):
        db = get_db()
        cursor = db.execute('INSERT INTO meals (name, date, recipe_id, meal_time) VALUES (?, ?, ?, ?)',
                            (name, date, recipe_id, meal_time))
        db.commit()
        return {
            "id": cursor.lastrowid,
            "name": name,
            "date": date,
            "recipe_id": recipe_id,
            "meal_time": meal_time
        }

    @staticmethod
    def update(meal_id, name=None, date=None, recipe_id=None, meal_time=None):
        db = get_db()
        query_parts = []
        params = []
        if name is not None:
            query_parts.append('name = ?')
            params.append(name)
        if date is not None:
            query_parts.append('date = ?')
            params.append(date)
        if recipe_id is not None:
            query_parts.append('recipe_id = ?')
            params.append(recipe_id)
        if meal_time is not None:
            query_parts.append('meal_time = ?')
            params.append(meal_time)

        if not query_parts:
            return 0

        query = 'UPDATE meals SET ' + ', '.join(query_parts) + ' WHERE id = ?'
        params.append(meal_id)
        cursor = db.execute(query, tuple(params))
        db.commit()
        return cursor.rowcount

    @staticmethod
    def delete(meal_id):
        db = get_db()
        cursor = db.execute('DELETE FROM meals WHERE id = ?', (meal_id,))
        db.commit()
        return cursor.rowcount

class RecipeIngredient:
    @staticmethod
    def get_for_recipe(recipe_id):
        db = get_db()
        cursor = db.execute('SELECT id, name, quantity FROM recipe_ingredients WHERE recipe_id = ?', (recipe_id,))
        return [row_to_dict(row) for row in cursor.fetchall()]

    @staticmethod
    def create(recipe_id, name, quantity=None):
        db = get_db()
        cursor = db.execute('INSERT INTO recipe_ingredients (recipe_id, name, quantity) VALUES (?, ?, ?)',
                            (recipe_id, name, quantity))
        db.commit()
        return cursor.lastrowid

    @staticmethod
    def delete_for_recipe(recipe_id):
        db = get_db()
        cursor = db.execute('DELETE FROM recipe_ingredients WHERE recipe_id = ?', (recipe_id,))
        db.commit()
        return cursor.rowcount


class Recipe:
    def __init__(self, id=None, name=None, instructions=None):
        self.id = id
        self.name = name
        self.instructions = instructions if instructions is not None else []

    @staticmethod
    def all():
        db = get_db()
        cursor = db.execute('SELECT * FROM recipes')
        recipes = []
        for row in cursor.fetchall():
            d = row_to_dict(row)
            d['ingredients'] = RecipeIngredient.get_for_recipe(d['id'])
            d['instructions'] = json.loads(d['instructions']) if d['instructions'] else []
            recipes.append(d)
        return recipes

    @staticmethod
    def get(recipe_id):
        db = get_db()
        cursor = db.execute('SELECT * FROM recipes WHERE id = ?', (recipe_id,))
        recipe = cursor.fetchone()
        if recipe:
            d = row_to_dict(recipe)
            d['ingredients'] = RecipeIngredient.get_for_recipe(recipe_id)
            d['instructions'] = json.loads(d['instructions']) if d['instructions'] else []
            return d
        return None

    @staticmethod
    def create(name, ingredients=None, instructions=None):
        db = get_db()
        instructions_json = json.dumps(instructions) if instructions is not None else json.dumps([])
        cursor = db.execute('INSERT INTO recipes (name, instructions) VALUES (?, ?)',
                            (name, instructions_json))
        recipe_id = cursor.lastrowid

        if ingredients:
            for ingredient in ingredients:
                RecipeIngredient.create(recipe_id, ingredient['name'], ingredient.get('quantity'))

        db.commit()
        return {
            "id": recipe_id,
            "name": name,
            "ingredients": ingredients if ingredients else [],
            "instructions": json.loads(instructions_json)
        }

    @staticmethod
    def update(recipe_id, name=None, ingredients=None, instructions=None):
        db = get_db()
        query_parts = []
        params = []
        if name is not None:
            query_parts.append('name = ?')
            params.append(name)
        if instructions is not None:
            query_parts.append('instructions = ?')
            params.append(json.dumps(instructions))

        if query_parts:
            query = 'UPDATE recipes SET ' + ', '.join(query_parts) + ' WHERE id = ?'
            params.append(recipe_id)
            db.execute(query, tuple(params))

        if ingredients is not None:
            RecipeIngredient.delete_for_recipe(recipe_id)
            for ingredient in ingredients:
                RecipeIngredient.create(recipe_id, ingredient['name'], ingredient.get('quantity'))

        db.commit()
        # Check if the recipe exists before claiming success
        cursor = db.execute('SELECT id FROM recipes WHERE id = ?', (recipe_id,))
        return 1 if cursor.fetchone() else 0


    @staticmethod
    def delete(recipe_id):
        db = get_db()
        RecipeIngredient.delete_for_recipe(recipe_id)
        cursor = db.execute('DELETE FROM recipes WHERE id = ?', (recipe_id,))
        db.commit()
        return cursor.rowcount

class GroceryItem:
    def __init__(self, id=None, name=None, quantity='', category='Other', is_completed=False):
        self.id = id
        self.name = name
        self.quantity = quantity
        self.category = category
        self.is_completed = is_completed

    @staticmethod
    def all():
        db = get_db()
        cursor = db.execute('SELECT * FROM grocery_items')
        return [row_to_dict(row) for row in cursor.fetchall()]

    @staticmethod
    def get(item_id):
        db = get_db()
        cursor = db.execute('SELECT * FROM grocery_items WHERE id = ?', (item_id,))
        item = cursor.fetchone()
        return row_to_dict(item) if item else None

    @staticmethod
    def create(name, quantity='', category='Other', is_completed=False):
        db = get_db()
        cursor = db.execute('INSERT INTO grocery_items (name, quantity, category, is_completed) VALUES (?, ?, ?, ?)',
                            (name, quantity, category, is_completed))
        db.commit()
        return {
            "id": cursor.lastrowid,
            "name": name,
            "quantity": quantity,
            "category": category,
            "is_completed": is_completed
        }

    @staticmethod
    def update(item_id, name=None, quantity=None, category=None, is_completed=None):
        db = get_db()
        query_parts = []
        params = []
        if name is not None:
            query_parts.append('name = ?')
            params.append(name)
        if quantity is not None:
            query_parts.append('quantity = ?')
            params.append(quantity)
        if category is not None:
            query_parts.append('category = ?')
            params.append(category)
        if is_completed is not None:
            query_parts.append('is_completed = ?')
            params.append(is_completed)

        if not query_parts:
            return 0

        query = 'UPDATE grocery_items SET ' + ', '.join(query_parts) + ' WHERE id = ?'
        params.append(item_id)
        cursor = db.execute(query, tuple(params))
        db.commit()
        return cursor.rowcount

    @staticmethod
    def delete(item_id):
        db = get_db()
        cursor = db.execute('DELETE FROM grocery_items WHERE id = ?', (item_id,))
        db.commit()
        return cursor.rowcount
