#!/bin/bash

# setup.sh - Prompt for API Key and Setup MCP Config

echo "🚀 Setting up your Class Material MCP Server..."

# Check for Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install it first."
    exit 1
fi

# Create Virtual Env if it doesn't exist
if [ ! -d ".venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv .venv
fi

source .venv/bin/activate
echo "📦 Installing dependencies (this may take a minute)..."
pip install -r requirements.txt --quiet

# Prompt for API Key
echo ""
read -p "🔑 Please enter your PINECONE_API_KEY: " API_KEY
echo ""

# Get the Current Directory (Absolute Path)
CURDIR=$(pwd)

# Generate the JSON Config
cat <<JSONEOF > mcp_config_snippet.json
{
  "lawr-class-materials": {
    "command": "$CURDIR/.venv/bin/python3",
    "args": ["$CURDIR/pinecone_mcp_server.py"],
    "env": {
      "PINECONE_API_KEY": "$API_KEY",
      "PINECONE_INDEX": "lawr-class-materials"
    }
  },
  "civpro-class-materials": {
    "command": "$CURDIR/.venv/bin/python3",
    "args": ["$CURDIR/pinecone_mcp_server.py"],
    "env": {
      "PINECONE_API_KEY": "$API_KEY",
      "PINECONE_INDEX": "civpro-class-materials"
    }
  }
}
JSONEOF

echo "✅ Success! Your MCP configuration is saved in: mcp_config_snippet.json"
echo "👉 Copy the contents of that file into your Gemini CLI or Claude settings."
