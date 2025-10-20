from database import get_db, row_to_dict
import json
import re
from werkzeug.security import generate_password_hash, check_password_hash

def parse_quantity_and_unit(quantity_str):
    """Parses a quantity string into a numerical value and a unit."""
    if not quantity_str:
        return 0.0, ''

    # Regex to find a number (integer or float) and an optional unit
    match = re.match(r'(\d+(\.\d+)?)\s*([a-zA-Z]+)?', quantity_str.strip())
    if match:
        value = float(match.group(1))
        unit = (match.group(3) or '').strip().lower()
        return value, unit
    
    # If no number found, try to convert the whole string to a number
    try:
        return float(quantity_str.strip()), ''
    except ValueError:
        return 0.0, quantity_str.strip().lower() # Treat as a unit if not a number

class Family:
    def __init__(self, id=None, name=None):
        self.id = id
        self.name = name

    @staticmethod
    def all():
        db = get_db()
        cursor = db.execute('SELECT * FROM families')
        return [row_to_dict(row) for row in cursor.fetchall()]

    @staticmethod
    def get(family_id):
        db = get_db()
        cursor = db.execute('SELECT * FROM families WHERE id = ?', (family_id,))
        family = cursor.fetchone()
        return row_to_dict(family) if family else None

    @staticmethod
    def get_by_name(name):
        db = get_db()
        cursor = db.execute('SELECT * FROM families WHERE name = ?', (name,))
        family = cursor.fetchone()
        return row_to_dict(family) if family else None

    @staticmethod
    def create(name):
        db = get_db()
        cursor = db.execute('INSERT INTO families (name) VALUES (?)', (name,))
        db.commit()
        return {
            "id": cursor.lastrowid,
            "name": name
        }

class User:
    def __init__(self, id=None, username=None, password_hash=None, email=None, is_accepted=False, family_id=None):
        self.id = id
        self.username = username
        self.password_hash = password_hash
        self.email = email
        self.is_accepted = is_accepted
        self.family_id = family_id

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
        print(f"DEBUG: Generated password hash: {self.password_hash}")

    @staticmethod
    def check_password(stored_password_hash, provided_password):
        print(f"DEBUG: Stored hash: {stored_password_hash}")
        print(f"DEBUG: Provided password: {provided_password}")
        result = check_password_hash(stored_password_hash, provided_password)
        print(f"DEBUG: Password check result: {result}")
        return result

    @staticmethod
    def all():
        db = get_db()
        cursor = db.execute('SELECT * FROM users')
        return [row_to_dict(row) for row in cursor.fetchall()]

    @staticmethod
    def get(user_id):
        db = get_db()
        cursor = db.execute('SELECT * FROM users WHERE id = ?', (user_id,))
        user = cursor.fetchone()
        return row_to_dict(user) if user else None

    @staticmethod
    def get_by_username(username):
        db = get_db()
        cursor = db.execute('SELECT * FROM users WHERE username = ?', (username,))
        user = cursor.fetchone()
        return row_to_dict(user) if user else None

    @staticmethod
    def get_by_family_id(family_id):
        db = get_db()
        cursor = db.execute('SELECT id, username, email, is_accepted, family_id FROM users WHERE family_id = ?', (family_id,))
        return [row_to_dict(row) for row in cursor.fetchall()]

    @staticmethod
    def create(username, password_hash, email, family_id, is_accepted=False):
        db = get_db()
        print(f"DEBUG: Storing user: {username}, hash: {password_hash}, email: {email}, is_accepted: {is_accepted}, family_id: {family_id}", flush=True)
        cursor = db.execute('INSERT INTO users (username, password_hash, email, is_accepted, family_id) VALUES (?, ?, ?, ?, ?)',
                            (username, password_hash, email, is_accepted, family_id))
        db.commit()
        return {
            "id": cursor.lastrowid,
            "username": username,
            "email": email,
            "is_accepted": is_accepted,
            "family_id": family_id
        }

    @staticmethod
    def update_acceptance_status(user_id, family_id, is_accepted):
        db = get_db()
        cursor = db.execute('UPDATE users SET is_accepted = ? WHERE id = ? AND family_id = ?',
                            (is_accepted, user_id, family_id))
        db.commit()
        return cursor.rowcount

class Task:
    def __init__(self, id=None, title=None, description=None, completed=False, family_id=None, user_id=None):
        self.id = id
        self.title = title
        self.description = description
        self.completed = completed
        self.family_id = family_id
        self.user_id = user_id

    @staticmethod
    def all(family_id):
        db = get_db()
        cursor = db.execute('SELECT * FROM tasks WHERE family_id = ?', (family_id,))
        return [row_to_dict(row) for row in cursor.fetchall()]

    @staticmethod
    def get(task_id, family_id):
        db = get_db()
        cursor = db.execute('SELECT * FROM tasks WHERE id = ? AND family_id = ?', (task_id, family_id))
        task = cursor.fetchone()
        return row_to_dict(task) if task else None

    @staticmethod
    def create(title, description='', completed=False, family_id=None, user_id=None):
        db = get_db()
        cursor = db.execute('INSERT INTO tasks (title, description, completed, family_id, user_id) VALUES (?, ?, ?, ?, ?)',
                            (title, description, completed, family_id, user_id))
        db.commit()
        return {
            "id": cursor.lastrowid,
            "title": title,
            "description": description,
            "completed": completed,
            "family_id": family_id,
            "user_id": user_id
        }

    @staticmethod
    def update(task_id, family_id, title=None, description=None, completed=None):
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

        query = 'UPDATE tasks SET ' + ', '.join(query_parts) + ' WHERE id = ? AND family_id = ?'
        params.append(task_id)
        params.append(family_id)
        cursor = db.execute(query, tuple(params))
        db.commit()
        return cursor.rowcount

    @staticmethod
    def delete(task_id, family_id):
        db = get_db()
        cursor = db.execute('DELETE FROM tasks WHERE id = ? AND family_id = ?', (task_id, family_id))
        db.commit()
        return cursor.rowcount

class Meal:
    def __init__(self, id=None, name=None, date=None, recipe_id=None, meal_time=None, family_id=None):
        self.id = id
        self.name = name
        self.date = date
        self.recipe_id = recipe_id
        self.meal_time = meal_time
        self.family_id = family_id

    @staticmethod
    def all(family_id):
        db = get_db()
        cursor = db.execute('SELECT * FROM meals WHERE family_id = ?', (family_id,))
        return [row_to_dict(row) for row in cursor.fetchall()]

    @staticmethod
    def get(meal_id, family_id):
        db = get_db()
        cursor = db.execute('SELECT * FROM meals WHERE id = ? AND family_id = ?', (meal_id, family_id))
        meal = cursor.fetchone()
        return row_to_dict(meal) if meal else None

    @staticmethod
    def create(name, date='', recipe_id=None, meal_time=None, family_id=None):
        db = get_db()
        cursor = db.execute('INSERT INTO meals (name, date, recipe_id, meal_time, family_id) VALUES (?, ?, ?, ?, ?)',
                            (name, date, recipe_id, meal_time, family_id))
        db.commit()
        return {
            "id": cursor.lastrowid,
            "name": name,
            "date": date,
            "recipe_id": recipe_id,
            "meal_time": meal_time,
            "family_id": family_id
        }

    @staticmethod
    def update(meal_id, family_id, name=None, date=None, recipe_id=None, meal_time=None):
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

        query = 'UPDATE meals SET ' + ', '.join(query_parts) + ' WHERE id = ? AND family_id = ?'
        params.append(meal_id)
        params.append(family_id)
        cursor = db.execute(query, tuple(params))
        db.commit()
        return cursor.rowcount

    @staticmethod
    def delete(meal_id, family_id):
        db = get_db()
        cursor = db.execute('DELETE FROM meals WHERE id = ? AND family_id = ?', (meal_id, family_id))
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
    def __init__(self, id=None, name=None, instructions=None, family_id=None):
        self.id = id
        self.name = name
        self.instructions = instructions if instructions is not None else []
        self.family_id = family_id

    @staticmethod
    def all(family_id):
        db = get_db()
        cursor = db.execute('SELECT * FROM recipes WHERE family_id = ?', (family_id,))
        recipes = []
        for row in cursor.fetchall():
            d = row_to_dict(row)
            d['ingredients'] = RecipeIngredient.get_for_recipe(d['id'])
            d['instructions'] = json.loads(d['instructions']) if d['instructions'] else []
            recipes.append(d)
        return recipes

    @staticmethod
    def get(recipe_id, family_id):
        db = get_db()
        cursor = db.execute('SELECT * FROM recipes WHERE id = ? AND family_id = ?', (recipe_id, family_id))
        recipe = cursor.fetchone()
        if recipe:
            d = row_to_dict(recipe)
            d['ingredients'] = RecipeIngredient.get_for_recipe(recipe_id)
            d['instructions'] = json.loads(d['instructions']) if d['instructions'] else []
            return d
        return None

    @staticmethod
    def create(name, ingredients=None, instructions=None, family_id=None):
        db = get_db()
        instructions_json = json.dumps(instructions) if instructions is not None else json.dumps([])
        cursor = db.execute('INSERT INTO recipes (name, instructions, family_id) VALUES (?, ?, ?)',
                            (name, instructions_json, family_id))
        recipe_id = cursor.lastrowid

        if ingredients:
            for ingredient in ingredients:
                RecipeIngredient.create(recipe_id, ingredient['name'], ingredient.get('quantity'))

        db.commit()
        return {
            "id": recipe_id,
            "name": name,
            "ingredients": ingredients if ingredients else [],
            "instructions": json.loads(instructions_json),
            "family_id": family_id
        }

    @staticmethod
    def update(recipe_id, family_id, name=None, ingredients=None, instructions=None):
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
            query = 'UPDATE recipes SET ' + ', '.join(query_parts) + ' WHERE id = ? AND family_id = ?'
            params.append(recipe_id)
            params.append(family_id)
            db.execute(query, tuple(params))

        if ingredients is not None:
            RecipeIngredient.delete_for_recipe(recipe_id)
            for ingredient in ingredients:
                RecipeIngredient.create(recipe_id, ingredient['name'], ingredient.get('quantity'))

        db.commit()
        # Check if the recipe exists before claiming success
        cursor = db.execute('SELECT id FROM recipes WHERE id = ? AND family_id = ?', (recipe_id, family_id))
        return 1 if cursor.fetchone() else 0


    @staticmethod
    def delete(recipe_id, family_id):
        db = get_db()
        RecipeIngredient.delete_for_recipe(recipe_id)
        cursor = db.execute('DELETE FROM recipes WHERE id = ? AND family_id = ?', (recipe_id, family_id))
        db.commit()
        return cursor.rowcount

class GroceryItem:
    def __init__(self, id=None, name=None, quantity='', category='Other', is_completed=False, family_id=None):
        self.id = id
        self.name = name
        self.quantity = quantity
        self.category = category
        self.is_completed = is_completed
        self.family_id = family_id

    @staticmethod
    def all(family_id):
        db = get_db()
        cursor = db.execute('SELECT * FROM grocery_items WHERE family_id = ?', (family_id,))
        return [row_to_dict(row) for row in cursor.fetchall()]

    @staticmethod
    def get(item_id, family_id):
        db = get_db()
        cursor = db.execute('SELECT * FROM grocery_items WHERE id = ? AND family_id = ?', (item_id, family_id))
        item = cursor.fetchone()
        return row_to_dict(item) if item else None

    @staticmethod
    def create(name, quantity='', category='Other', is_completed=False, family_id=None):
        db = get_db()
        cursor = db.execute('INSERT INTO grocery_items (name, quantity, category, is_completed, family_id) VALUES (?, ?, ?, ?, ?)',
                            (name, quantity, category, is_completed, family_id))
        db.commit()
        return {
            "id": cursor.lastrowid,
            "name": name,
            "quantity": quantity,
            "category": category,
            "is_completed": is_completed,
            "family_id": family_id
        }

    @staticmethod
    def update(item_id, family_id, name=None, quantity=None, category=None, is_completed=None):
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

        query = 'UPDATE grocery_items SET ' + ', '.join(query_parts) + ' WHERE id = ? AND family_id = ?'
        params.append(item_id)
        params.append(family_id)
        cursor = db.execute(query, tuple(params))
        db.commit()
        return cursor.rowcount

    @staticmethod
    def delete(item_id, family_id):
        db = get_db()
        cursor = db.execute('DELETE FROM grocery_items WHERE id = ? AND family_id = ?', (item_id, family_id))
        db.commit()
        return cursor.rowcount

    @staticmethod
    def find_by_name_and_unit(name, unit, family_id):
        """Finds an existing grocery item by normalized name and unit within a family."""
        db = get_db()
        normalized_name = name.strip().lower().replace(' ', '')
        
        # Get all grocery items for the specific family and check for matches
        cursor = db.execute('SELECT * FROM grocery_items WHERE family_id = ?', (family_id,))
        for row in cursor.fetchall():
            item = row_to_dict(row)
            item_normalized_name = item['name'].strip().lower().replace(' ', '')
            
            if item_normalized_name == normalized_name:
                # Parse the quantity and unit of the existing item
                _, item_unit = parse_quantity_and_unit(item['quantity'])
                
                # Check if units match (both empty or both the same)
                if item_unit == unit:
                    return item
        
        return None

class Thought:
    def __init__(self, id=None, content=None, timestamp=None, user_id=None, family_id=None):
        self.id = id
        self.content = content
        self.timestamp = timestamp
        self.user_id = user_id
        self.family_id = family_id

    @staticmethod
    def all(family_id, page=1, limit=10):
        db = get_db()
        offset = (page - 1) * limit
        cursor = db.execute('''
            SELECT t.id, t.content, t.timestamp, t.user_id, u.username, u.email, u.is_accepted, u.family_id
            FROM thoughts t
            JOIN users u ON t.user_id = u.id
            WHERE t.family_id = ?
            ORDER BY t.timestamp DESC
            LIMIT ? OFFSET ?
        ''', (family_id, limit, offset))
        
        thoughts_data = []
        for row in cursor.fetchall():
            thought_dict = row_to_dict(row)
            # Reconstruct the user object from the joined data
            user_data = {
                'id': thought_dict['user_id'],
                'username': thought_dict['username'],
                'email': thought_dict['email'],
                'is_accepted': thought_dict['is_accepted'],
                'family_id': thought_dict['family_id']
            }
            thought_dict['user'] = user_data
            del thought_dict['username']
            del thought_dict['email']
            del thought_dict['is_accepted']
            del thought_dict['family_id'] # Remove family_id from thought_dict as it's now nested under user
            thoughts_data.append(thought_dict)
        return thoughts_data

    @staticmethod
    def get(thought_id, family_id):
        db = get_db()
        cursor = db.execute('''
            SELECT t.id, t.content, t.timestamp, t.user_id, u.username, u.email, u.is_accepted, u.family_id
            FROM thoughts t
            JOIN users u ON t.user_id = u.id
            WHERE t.id = ? AND t.family_id = ?
        ''', (thought_id, family_id))
        thought = cursor.fetchone()
        if thought:
            thought_dict = row_to_dict(thought)
            user_data = {
                'id': thought_dict['user_id'],
                'username': thought_dict['username'],
                'email': thought_dict['email'],
                'is_accepted': thought_dict['is_accepted'],
                'family_id': thought_dict['family_id']
            }
            thought_dict['user'] = user_data
            del thought_dict['username']
            del thought_dict['email']
            del thought_dict['is_accepted']
            del thought_dict['family_id']
            return thought_dict
        return None

    @staticmethod
    def create(content, user_id, family_id):
        db = get_db()
        cursor = db.execute('INSERT INTO thoughts (content, user_id, family_id) VALUES (?, ?, ?)',
                            (content, user_id, family_id))
        db.commit()
        # Fetch the newly created thought with user details
        return Thought.get(cursor.lastrowid, family_id)
