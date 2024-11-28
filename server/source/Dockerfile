# Use the official Python image from Docker Hub
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory content into the container
COPY . /app

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt
# Expose the port that FastAPI will run on
EXPOSE 8080

# Run the FastAPI application with Uvicorn
CMD ["uvicorn", "server_app:app", "--host", "*", "--port", "8080"]

