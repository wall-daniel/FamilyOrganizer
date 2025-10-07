from flask import Flask
from database import init_app
from routes import bp as api_bp
from flask_cors import CORS  # Add this import

def create_app():
    app = Flask(__name__)
    app.config['SECRET_KEY'] = 'dev' # Replace with a strong secret key in production

    init_app(app)
    app.register_blueprint(api_bp)
    CORS(app)  # Enable CORS for all routes

    @app.route('/')
    def hello():
        return "Family Organizer API is running!"

    return app

app = create_app()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)
