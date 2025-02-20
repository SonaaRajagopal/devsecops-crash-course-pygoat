# Use a stable Python version
FROM python:3.11-slim

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    dnsutils \
    libpq-dev \
    python3-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Upgrade pip first
RUN python -m pip install --upgrade pip

# Copy requirements file explicitly
COPY requirements.txt /app/requirements.txt

# Install dependencies
RUN pip install --no-cache-dir -r /app/requirements.txt || cat /app/requirements.txt

# Copy project files
COPY . /app/

# Expose port
EXPOSE 8000

# Run database migrations
RUN python3 manage.py migrate

# Set working directory for PyGoat
WORKDIR /app/pygoat/

# Start Gunicorn server
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.wsgi"]
