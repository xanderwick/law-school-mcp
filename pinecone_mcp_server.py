#!/usr/bin/env python3
"""
pinecone_mcp_server.py — MCP server for querying class materials in Pinecone

Each class gets its own entry in claude_desktop_config.json pointing to the
same script but with a different PINECONE_INDEX env var. Example:

{
  "mcpServers": {
    "lawr-class-materials": {
      "command": "/Library/Frameworks/Python.framework/Versions/3.12/bin/python3",
      "args": ["/Users/xanderwick/Downloads/pinecone_mcp_server.py"],
      "env": {
        "PINECONE_API_KEY": "your-key-here",
        "PINECONE_INDEX": "lawr-class-materials"
      }
    },
    "contracts-class-materials": {
      "command": "/Library/Frameworks/Python.framework/Versions/3.12/bin/python3",
      "args": ["/Users/xanderwick/Downloads/pinecone_mcp_server.py"],
      "env": {
        "PINECONE_API_KEY": "your-key-here",
        "PINECONE_INDEX": "contracts-class-materials"
      }
    }
  }
}
"""

import os
from mcp.server.fastmcp import FastMCP

INDEX_NAME = os.environ.get("PINECONE_INDEX", "lawr-class-materials")

mcp = FastMCP(INDEX_NAME)

# Lazy-loaded globals so startup is fast
_model = None
_index = None


def _get_model():
    global _model
    if _model is None:
        from sentence_transformers import SentenceTransformer
        _model = SentenceTransformer("all-MiniLM-L6-v2")
    return _model


def _get_index():
    global _index
    if _index is None:
        from pinecone import Pinecone
        api_key = os.environ.get("PINECONE_API_KEY")
        if not api_key:
            raise RuntimeError("PINECONE_API_KEY environment variable is not set")
        pc = Pinecone(api_key=api_key)
        _index = pc.Index(INDEX_NAME)
    return _index


@mcp.tool()
def query_class_materials(question: str, top_k: int = 6) -> str:
    """
    Search the class materials knowledge base and return the most relevant passages.

    Args:
        question: The question or topic to search for
        top_k: Number of results to return (default 6, max 20)
    """
    top_k = min(top_k, 20)

    model = _get_model()
    index = _get_index()

    embedding = model.encode(question).tolist()
    results = index.query(vector=embedding, top_k=top_k, include_metadata=True)

    if not results.matches:
        return f"No relevant results found in {INDEX_NAME}."

    parts = []
    for i, match in enumerate(results.matches, 1):
        source = match.metadata.get("source_file", "unknown")
        file_type = match.metadata.get("file_type", "")
        text = match.metadata.get("text", "").strip()
        score = match.score
        label = f"{source} ({file_type})" if file_type else source
        parts.append(f"[{i}] {label}  |  relevance: {score:.3f}\n\n{text}")

    return "\n\n---\n\n".join(parts)


if __name__ == "__main__":
    mcp.run()
