from flask import Flask
from database import init_app
from routes import bp as api_bp
from flask_cors import CORS
from alembic.config import Config
from alembic import command
import os

def create_app():
    app = Flask(__name__)
    app.config['SECRET_KEY'] = 'dev' # Replace with a strong secret key in production

    init_app(app)

    # Function to apply migrations
    def apply_migrations():
        alembic_cfg = Config(os.path.join(app.root_path, 'alembic.ini'))
        alembic_cfg.set_main_option("script_location", os.path.join(app.root_path, 'alembic'))
        with app.app_context():
            command.upgrade(alembic_cfg, "head")
            print("Database migrations applied automatically.")

    # Apply migrations when the app starts
    apply_migrations()

    app.register_blueprint(api_bp)
    CORS(app, resources={r"/api/*": {"origins": "*"}})  # Enable CORS for all /api routes

    @app.route('/')
    def hello():
        return "Family Organizer API is running!"

    return app

app = create_app()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)
