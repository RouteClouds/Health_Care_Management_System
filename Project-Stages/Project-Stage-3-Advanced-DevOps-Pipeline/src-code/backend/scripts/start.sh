#!/bin/bash

# Backend startup script with automatic database initialization
# This ensures the database is ready before the application starts

set -e

echo "🚀 Starting Healthcare Backend..."
echo "================================"

# Run database initialization
if [ -f "./scripts/init-db.sh" ]; then
    echo "🗄️ Running database initialization..."
    ./scripts/init-db.sh
else
    echo "⚠️ Database initialization script not found, skipping..."
fi

# Start the application
echo "🏥 Starting Healthcare Management System API..."
exec npm start
