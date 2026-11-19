# Base Python image with Python 3.10 on Debian slim
FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app/src:$PYTHONPATH

# Set working directory inside container
WORKDIR /app

# Install system dependencies (including awscli for cloud deployments)
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    awscli \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency specifications first to leverage Docker layer caching
COPY requirements.txt .

# Upgrade pip and install Python dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application source code and configurations
COPY . /app

# Install local package in editable mode without re-resolving dependencies
RUN pip install --no-cache-dir -e . --no-deps

# Expose web application port
EXPOSE 8080

# Launch Flask application
CMD ["python3", "app.py"]
