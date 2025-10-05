from database import get_db, row_to_dict

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
    def __init__(self, id=None, name=None, date=None, recipe_id=None):
        self.id = id
        self.name = name
        self.date = date
        self.recipe_id = recipe_id

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
    def create(name, date='', recipe_id=None):
        db = get_db()
        cursor = db.execute('INSERT INTO meals (name, date, recipe_id) VALUES (?, ?, ?)',
                            (name, date, recipe_id))
        db.commit()
        return {
            "id": cursor.lastrowid,
            "name": name,
            "date": date,
            "recipe_id": recipe_id
        }

    @staticmethod
    def update(meal_id, name=None, date=None, recipe_id=None):
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

class Recipe:
    def __init__(self, id=None, name=None, ingredients=None, instructions=None):
        self.id = id
        self.name = name
        self.ingredients = ingredients
        self.instructions = instructions

    @staticmethod
    def all():
        db = get_db()
        cursor = db.execute('SELECT * FROM recipes')
        return [row_to_dict(row) for row in cursor.fetchall()]

    @staticmethod
    def get(recipe_id):
        db = get_db()
        cursor = db.execute('SELECT * FROM recipes WHERE id = ?', (recipe_id,))
        recipe = cursor.fetchone()
        return row_to_dict(recipe) if recipe else None

    @staticmethod
    def create(name, ingredients='', instructions=''):
        db = get_db()
        cursor = db.execute('INSERT INTO recipes (name, ingredients, instructions) VALUES (?, ?, ?)',
                            (name, ingredients, instructions))
        db.commit()
        return {
            "id": cursor.lastrowid,
            "name": name,
            "ingredients": ingredients,
            "instructions": instructions
        }

    @staticmethod
    def update(recipe_id, name=None, ingredients=None, instructions=None):
        db = get_db()
        query_parts = []
        params = []
        if name is not None:
            query_parts.append('name = ?')
            params.append(name)
        if ingredients is not None:
            query_parts.append('ingredients = ?')
            params.append(ingredients)
        if instructions is not None:
            query_parts.append('instructions = ?')
            params.append(instructions)

        if not query_parts:
            return 0

        query = 'UPDATE recipes SET ' + ', '.join(query_parts) + ' WHERE id = ?'
        params.append(recipe_id)
        cursor = db.execute(query, tuple(params))
        db.commit()
        return cursor.rowcount

    @staticmethod
    def delete(recipe_id):
        db = get_db()
        cursor = db.execute('DELETE FROM recipes WHERE id = ?', (recipe_id,))
        db.commit()
        return cursor.rowcount

class GroceryItem:
    def __init__(self, id=None, name=None, quantity=None, is_completed=False):
        self.id = id
        self.name = name
        self.quantity = quantity
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
    def create(name, quantity='', is_completed=False):
        db = get_db()
        cursor = db.execute('INSERT INTO grocery_items (name, quantity, is_completed) VALUES (?, ?, ?)',
                            (name, quantity, is_completed))
        db.commit()
        return {
            "id": cursor.lastrowid,
            "name": name,
            "quantity": quantity,
            "is_completed": is_completed
        }

    @staticmethod
    def update(item_id, name=None, quantity=None, is_completed=None):
        db = get_db()
        query_parts = []
        params = []
        if name is not None:
            query_parts.append('name = ?')
            params.append(name)
        if quantity is not None:
            query_parts.append('quantity = ?')
            params.append(quantity)
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
