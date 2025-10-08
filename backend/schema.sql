DROP TABLE IF EXISTS tasks;
DROP TABLE IF EXISTS meals;
DROP TABLE IF EXISTS recipes;
DROP TABLE IF EXISTS grocery_items;

CREATE TABLE tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT 0
);

CREATE TABLE grocery_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    quantity TEXT,
    category TEXT DEFAULT 'Other',
    is_completed BOOLEAN DEFAULT 0
);

CREATE TABLE meals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    date TEXT,
    recipe_id INTEGER,
    meal_time TEXT,
    FOREIGN KEY (recipe_id) REFERENCES recipes(id)
);

CREATE TABLE recipes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    ingredients TEXT, -- JSON-encoded list of strings
    instructions TEXT -- JSON-encoded list of strings
);
