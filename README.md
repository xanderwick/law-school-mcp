# 📚 Law School MCP Servers

This repository allows you to connect your AI assistant (Gemini CLI or Claude) to shared law school class materials hosted in a Pinecone vector database.

## 🚀 Quick Start (For Beginners)

### 1. Clone the Repository
\`\`\`bash
git clone https://github.com/xanderwick/law-school-mcp.git
cd law-school-mcp
\`\`\`

### 2. Run the Setup
In your terminal, simply run:
\`\`\`bash
make setup
\`\`\`
*This script will create a virtual environment, install the tools, and prompt you for your API key.*

### 3. Update your Settings
1. Open the file \`mcp_config_snippet.json\` that was just created.
2. Copy the contents into your AI client's configuration file (e.g., \`~/.gemini/settings.json\`).

## 🛠️ Requirements
- Python 3.10 or higher
- A Pinecone API Key
