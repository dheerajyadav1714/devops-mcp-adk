import os
from google.adk.agents import Agent
from toolbox_core import ToolboxSyncClient

# URL of the MCP Toolbox server (set in environment)
MCP_SERVER_URL = os.environ.get("MCP_SERVER_URL")

# Connect to the MCP server (public, no authentication)
toolbox = ToolboxSyncClient(MCP_SERVER_URL)

# Load the toolset defined in tools.yaml
tools = toolbox.load_toolset("devops_toolset")

root_agent = Agent(
    name="devops_failure_analyzer",
    model="gemini-2.5-flash",
    description="Analyzes CI/CD pipeline failures",
    instruction="""
    You are a senior DevOps engineer.

    Your job:
    1. Fetch failed pipeline logs using tools
    2. Identify root cause
    3. Categorize issue:
        - Infrastructure issue
        - Configuration issue
        - Application issue
    4. Suggest fix

    If logs contain:
    - 'no space left' → Disk issue
    - 'IAM' → Permission issue
    - 'crashloop' → Application issue

    Return structured output:
    - Pipeline ID
    - Root Cause
    - Category
    - Suggested Fix
    """,
    tools=tools,
)
