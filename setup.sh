#!/bin/bash

# setup.sh - Automatically Update MCP Config for Gemini & Claude

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

# Create the Python logic for merging JSON
PYTHON_LOGIC=$(cat <<EOF
import json
import os
import sys

new_servers = {
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

def update_json(path):
    if not os.path.exists(os.path.dirname(path)):
        return False
    
    config = {}
    if os.path.exists(path):
        with open(path, 'r') as f:
            try:
                config = json.load(f)
            except:
                config = {}
    
    if "mcpServers" not in config:
        config["mcpServers"] = {}
    
    config["mcpServers"].update(new_servers)
    
    with open(path, 'w') as f:
        json.dump(config, f, indent=2)
    return True

# Update Gemini CLI
gemini_path = os.path.expanduser("~/.gemini/settings.json")
if update_json(gemini_path):
    print(f"✅ Updated Gemini CLI settings: {gemini_path}")

# Update Claude Desktop (macOS)
if sys.platform == "darwin":
    claude_path = os.path.expanduser("~/Library/Application Support/Claude/claude_desktop_config.json")
    if update_json(claude_path):
        print(f"✅ Updated Claude Desktop settings: {claude_path}")
EOF
)

# Run the Python logic
python3 -c "$PYTHON_LOGIC"

echo ""
echo "🎉 Setup Complete! Please restart your AI client (Gemini or Claude) to see the new tools."
