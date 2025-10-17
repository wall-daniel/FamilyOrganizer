import jwt
from functools import wraps
from flask import request, jsonify, current_app, g
from models import User

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        if 'x-access-token' in request.headers:
            token = request.headers['x-access-token']

        if not token:
            return jsonify({'message': 'Token is missing!'}), 401

        print(token, flush=True)
        try:
            print("Secret key " + str(current_app.config['SECRET_KEY']), flush=True)
            data = jwt.decode(token, current_app.config['SECRET_KEY'], algorithms=["HS256"])
            current_user = User.query.filter_by(id=data['id']).first()
            print(current_user, flush=True)
            if not current_user:
                return jsonify({'message': 'Token is invalid!'}), 401
            g.current_user = current_user
        except Exception as e:
            print(e, flush=True)
            return jsonify({'message': 'Token is invalid!'}), 401

        return f(*args, **kwargs)

    return decorated
