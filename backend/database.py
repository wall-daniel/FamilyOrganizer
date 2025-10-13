from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, scoped_session
from sqlalchemy.ext.declarative import declarative_base
from flask import g

DATABASE_URL = 'sqlite:////data/app/database.db'

engine = create_engine(DATABASE_URL)
db_session = scoped_session(sessionmaker(autocommit=False,
                                         autoflush=False,
                                         bind=engine))

Base = declarative_base()
Base.query = db_session.query_property()

def get_db():
    if 'db_session' not in g:
        g.db_session = db_session()
    return g.db_session

def close_connection(exception=None):
    db = g.pop('db_session', None)
    if db is not None:
        db.close()

def init_app(app):
    app.teardown_appcontext(close_connection)
