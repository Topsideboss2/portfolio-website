# Stage 1: Build
FROM python:3.12-slim AS build

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc \
    build-essential \
    libpq-dev \
    python3-psycopg2 \
    curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy only the requirements file and install dependencies
COPY requirements.txt /app/
RUN pip install --upgrade pip setuptools && \
    pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . /app/

# Stage 2: Production
FROM python:3.12-slim AS production

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    libpq-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create and set the working directory
WORKDIR /app

# Copy installed dependencies from the build stage
COPY --from=build /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages

# Copy the application code and static files from the build stage
COPY --from=build /app /app

# Collect static files
# RUN python manage.py collectstatic --noinput

# Ensure that the entrypoint.sh script is executable
RUN chmod +x /app/entrypoint.sh

# Set permissions
RUN chown -R nobody:nogroup /app

# Switch to a non-root user
USER nobody

# Expose necessary ports
EXPOSE 8000
EXPOSE 80
EXPOSE 443

# Run entrypoint.sh when the container launches
ENTRYPOINT ["/app/entrypoint.sh"]

# Start the application 
# CMD [ "python" "manage.py" "runserver" "0.0.0.0:8000" ]

# Start the application with Gunicorn
# CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "--threads", "4", "multitenantsaas.wsgi:application"]