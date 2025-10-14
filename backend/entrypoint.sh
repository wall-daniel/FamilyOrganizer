#!/bin/bash
set -e

# Ensure the data directory exists
mkdir -p /data/app

# Apply database migrations
echo "Applying database migrations..."
alembic upgrade head
echo "Database migrations applied."

# Start Gunicorn
echo "Starting Gunicorn server..."
exec gunicorn --bind 0.0.0.0:8080 app:app
