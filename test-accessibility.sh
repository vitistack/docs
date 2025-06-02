#!/bin/bash

# Local accessibility testing script for Vitistack docs
# This script runs the same accessibility tests as the CI pipeline

set -e

echo "🔍 Starting accessibility tests for Vitistack docs..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to find available port
find_available_port() {
    local port=8080
    if command_exists lsof; then
        while lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; do
            port=$((port + 1))
        done
    else
        # Fallback: try to bind to port using netcat or python
        while netstat -an 2>/dev/null | grep -q ":$port "; do
            port=$((port + 1))
        done
    fi
    echo $port
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to cleanup
cleanup() {
    echo -e "\n🧹 Cleaning up..."
    if [ ! -z "$SERVER_PID" ]; then
        kill $SERVER_PID 2>/dev/null || true
        wait $SERVER_PID 2>/dev/null || true
    fi
    # Kill any remaining python servers on common ports
    for port in 8080 8081 8082 8083; do
        if lsof -ti :$port >/dev/null 2>&1; then
            echo "Killing process on port $port"
            lsof -ti :$port | xargs kill -9 2>/dev/null || true
        fi
    done
    # Deactivate virtual environment
    if [ ! -z "$VIRTUAL_ENV" ]; then
        deactivate 2>/dev/null || true
    fi
}

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command_exists node; then
    echo -e "${RED}❌ Node.js is required but not installed.${NC}"
    exit 1
fi

if ! command_exists npm; then
    echo -e "${RED}❌ npm is required but not installed.${NC}"
    exit 1
fi

if ! command_exists python3; then
    echo -e "${RED}❌ Python 3 is required but not installed.${NC}"
    exit 1
fi

if ! command_exists curl; then
    echo -e "${RED}❌ curl is required but not installed.${NC}"
    exit 1
fi

if ! command_exists lsof; then
    echo -e "${YELLOW}⚠️  lsof not found. Port checking may not work properly.${NC}"
fi

# Setup Python virtual environment
echo "🐍 Setting up Python virtual environment..."
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Install Python dependencies
echo "📦 Installing Python dependencies..."
pip install --upgrade pip
pip install mkdocs-material
pip install -r mkdocs-requirements.txt

# Install Node.js dependencies
echo "📦 Installing accessibility testing tools..."
if [ ! -d "node_modules" ]; then
    npm install
fi

# Build the documentation
echo "🏗️  Building documentation..."
mkdocs build

# Find available port
PORT=$(find_available_port)
echo "🔍 Using port: $PORT"

# Start local server
echo "🚀 Starting local server on port $PORT..."
cd site
python3 -m http.server $PORT &
SERVER_PID=$!
cd ..

# Wait for server to start
echo "⏳ Waiting for server to start..."
sleep 5

# Set trap to cleanup on exit
trap cleanup EXIT

# Test if server is running
BASE_URL="http://localhost:$PORT"
if ! curl -s $BASE_URL > /dev/null; then
    echo -e "${RED}❌ Server is not responding at $BASE_URL${NC}"
    exit 1
fi

echo -e "✅ Server is running at $BASE_URL"

# Run accessibility tests
echo -e "\n${BLUE}🔍 Running accessibility tests...${NC}"

echo -e "\n${BLUE}1. Running Axe Core tests...${NC}"
if npx axe $BASE_URL --exit --verbose; then
    echo -e "${GREEN}✅ Axe Core tests passed${NC}"
else
    echo -e "${YELLOW}⚠️  Axe Core found accessibility issues${NC}"
fi

echo -e "\n${BLUE}2. Running Pa11y tests...${NC}"
if npx pa11y $BASE_URL; then
    echo -e "${GREEN}✅ Pa11y tests passed${NC}"
else
    echo -e "${YELLOW}⚠️  Pa11y found accessibility issues${NC}"
fi

echo -e "\n${BLUE}3. Running Lighthouse accessibility audit...${NC}"
if npx lhci collect --url=$BASE_URL; then
    echo -e "${GREEN}✅ Lighthouse collection completed${NC}"
    if npx lhci assert; then
        echo -e "${GREEN}✅ Lighthouse tests passed${NC}"
    else
        echo -e "${YELLOW}⚠️  Lighthouse found accessibility issues${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Lighthouse collection failed${NC}"
fi

echo -e "\n${GREEN}🎉 Accessibility testing complete!${NC}"
echo -e "📊 Check the generated reports for detailed results."
echo -e "🌐 Your site was tested at: $BASE_URL"
