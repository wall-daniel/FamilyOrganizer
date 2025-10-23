from flask import Flask
from database import init_app, db
from routes import bp as api_bp
from flask_cors import CORS
from flask_migrate import Migrate

def create_app():
    app = Flask(__name__)
    app.config['SECRET_KEY'] = 'dev' # Replace with a strong secret key in production
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:////data/app/database.db'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    init_app(app)
    migrate = Migrate(app, db, directory='/app/backend/migrations')
    app.register_blueprint(api_bp)
    CORS(app, resources={r"/api/*": {"origins": "*"}})  # Enable CORS for all /api routes

    @app.route('/')
    def hello():
        return "Family Organizer API is running!"

    return app

app = create_app()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)
