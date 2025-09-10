#!/bin/bash

# Smart Home Automation System - Run Script
echo "🏠 Smart Home Automation System"
echo "================================"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${RED}Port $1 is busy${NC}"
        return 1
    fi
    return 0
}

echo -e "${BLUE}Checking dependencies...${NC}"
if ! command_exists node; then
    echo -e "${RED}Node.js required. Install from https://nodejs.org${NC}"
    exit 1
fi

if ! command_exists npm; then
    echo -e "${RED}npm required${NC}"
    exit 1
fi

echo -e "${GREEN}Dependencies OK!${NC}"

while true; do
    echo ""
    echo "Select an option:"
    echo "1) Frontend Dashboard (React) - http://localhost:3000"
    echo "2) Backend Server (Node.js) - http://localhost:5000" 
    echo "3) Full Stack (Frontend + Backend)"
    echo "4) Mobile App (React Native)"
    echo "5) ML Training"
    echo "6) Hardware Simulator"
    echo "7) Setup Project"
    echo "8) Exit"
    
    read -p "Choice (1-8): " choice
    
    case $choice in
        1)
            echo -e "${BLUE}Starting Frontend...${NC}"
            if check_port 3000; then
                cd frontend && npm start
            fi
            ;;
        2)
            echo -e "${BLUE}Starting Backend...${NC}"
            if check_port 5000; then
                cd backend && npm run dev
            fi
            ;;
        3)
            echo -e "${BLUE}Starting Full Stack...${NC}"
            if check_port 5000 && check_port 3000; then
                cd backend && npm run dev &
                sleep 2
                cd ../frontend && npm start
            fi
            ;;
        4)
            echo -e "${BLUE}Starting Mobile App...${NC}"
            cd mobile && expo start
            ;;
        5)
            echo -e "${BLUE}Training ML Models...${NC}"
            cd backend/ml && python3 train_model.py
            ;;
        6)
            echo -e "${BLUE}Starting Hardware Simulator...${NC}"
            cd hardware && python3 arduino_simulator.py
            ;;
        7)
            echo -e "${BLUE}Setting up project...${NC}"
            ./setup.sh
            ;;
        8)
            echo -e "${GREEN}Goodbye! 👋${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            ;;
    esac
done