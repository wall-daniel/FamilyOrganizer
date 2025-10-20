# Use an official Python runtime as a parent image
FROM python:3.9-slim-buster

# Set the working directory in the container
WORKDIR /app

# Create the directory for the SQLite database
RUN mkdir -p data/app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Expose port 8080 for the application
EXPOSE 8080

# Run the application using Gunicorn
# Gunicorn is a WSGI HTTP Server for UNIX. It's a pre-fork worker model.
# The --bind 0.0.0.0:8080 makes it listen on all network interfaces on port 8080.
# The app:create_app specifies the callable 'create_app' inside 'app.py'
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--log-level", "debug", "wsgi:app"]
