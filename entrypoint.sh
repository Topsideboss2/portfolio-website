#!/bin/bash

# Makemigrations
python manage.py makemigrations

# Apply database migrations
python manage.py migrate

# Start the Django server
python manage.py runserver 0.0.0.0:8000