DROP TABLE IF EXISTS tasks;
DROP TABLE IF EXISTS meals;
DROP TABLE IF EXISTS recipes;
DROP TABLE IF EXISTS grocery_items;
DROP TABLE IF EXISTS thoughts; -- Add this line
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS families;

CREATE TABLE families (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL
);

CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    email TEXT NOT NULL,
    is_accepted BOOLEAN DEFAULT 0,
    family_id INTEGER NOT NULL,
    FOREIGN KEY (family_id) REFERENCES families(id)
);

CREATE TABLE tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT 0,
    family_id INTEGER NOT NULL,
    user_id INTEGER,
    FOREIGN KEY (family_id) REFERENCES families(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE grocery_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    quantity TEXT,
    category TEXT DEFAULT 'Other',
    is_completed BOOLEAN DEFAULT 0,
    family_id INTEGER NOT NULL,
    FOREIGN KEY (family_id) REFERENCES families(id)
);

CREATE TABLE meals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    date TEXT,
    recipe_id INTEGER,
    meal_time TEXT,
    family_id INTEGER NOT NULL,
    FOREIGN KEY (recipe_id) REFERENCES recipes(id),
    FOREIGN KEY (family_id) REFERENCES families(id)
);

CREATE TABLE recipes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    instructions TEXT, -- JSON-encoded list of strings
    family_id INTEGER NOT NULL,
    FOREIGN KEY (family_id) REFERENCES families(id)
);

CREATE TABLE recipe_ingredients (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    recipe_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    quantity TEXT,
    FOREIGN KEY (recipe_id) REFERENCES recipes(id)
);
