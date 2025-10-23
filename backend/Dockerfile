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

# Make the entrypoint script executable
RUN chmod +x /app/entrypoint.sh

# Expose port 8080 for the application
EXPOSE 8080

# Set the entrypoint script
ENTRYPOINT ["/app/entrypoint.sh"]
