from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

def init_app(app):
    db.init_app(app)
    # We no longer need db.create_all() here as migrations will handle it.
    # with app.app_context():
    #     db.create_all()
