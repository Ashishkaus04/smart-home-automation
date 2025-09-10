#!/bin/bash

echo "🔧 Setting up Smart Home Automation System"
echo "=========================================="

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Create directories
echo -e "${BLUE}Creating directories...${NC}"
mkdir -p frontend/src frontend/public
mkdir -p backend/routes backend/models backend/ml
mkdir -p mobile
mkdir -p hardware/arduino_code hardware/raspberry_pi

# Install Frontend Dependencies
echo -e "${BLUE}Installing frontend dependencies...${NC}"
cd frontend
if [ ! -f "package.json" ]; then
    npm init -y
    npm install react react-dom react-scripts lucide-react axios socket.io-client
fi
npm install

# Install Backend Dependencies  
echo -e "${BLUE}Installing backend dependencies...${NC}"
cd ../backend
if [ ! -f "package.json" ]; then
    npm init -y
    npm install express cors socket.io mongoose dotenv bcryptjs jsonwebtoken node-cron
    npm install --save-dev nodemon
fi
npm install

# Setup Mobile
echo -e "${BLUE}Setting up mobile...${NC}"
cd ../mobile
if command -v expo >/dev/null 2>&1; then
    if [ ! -f "package.json" ]; then
        expo init . --template blank
    fi
else
    echo "Install Expo CLI: npm install -g expo-cli"
fi

echo -e "${GREEN}✅ Setup complete!${NC}"
echo "Run ./run.sh to start the application"