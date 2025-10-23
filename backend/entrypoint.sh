#!/bin/sh
set -e

# Wait for the database to be ready
# This is a simple loop, in a real production scenario, you might want a more robust solution
# like wait-for-it.sh or docker-compose healthchecks.
# For SQLite, this is not strictly necessary but is good practice for other DBs.

echo "Running database migrations..."
flask db upgrade

echo "Starting Gunicorn..."
exec gunicorn --bind 0.0.0.0:8080 wsgi:app
