```markdown
# DevOps MCP Agent with ADK

This project demonstrates an AI agent built with the **Agent Development Kit (ADK)** that connects to a **Model Context Protocol (MCP)** server to retrieve real‑world data from BigQuery and answer questions about CI/CD pipeline failures.

## Architecture

- **MCP Toolbox server** – a public MCP server (deployed on Cloud Run) that exposes a BigQuery tool.  
- **ADK agent** – a Gemini‑powered agent that uses the MCP client (`toolbox_core`) to call the MCP server and format responses.

## Prerequisites

- A Google Cloud project with billing enabled.
- [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) installed and authenticated.
- Docker installed locally (for building the MCP server).
- Python 3.10+ with virtual environment support.

## Step‑by‑Step Deployment

### 1. Set up BigQuery data

Run the provided script to create a dataset and insert sample pipeline logs:

```bash
cd bigquery-setup
Make the script executable:
chmod +x bigquery-setup/setup_bigquery.sh
./setup_bigquery.sh
```

This creates a table `devops.pipeline_logs` with three failed pipeline examples.

### 2. Deploy the MCP Toolbox server

```bash
cd mcp-toolbox-server

# Build and push the container image
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/mcp-toolbox-server .

# Deploy to Cloud Run
gcloud run deploy mcp-toolbox-server \
  --image gcr.io/YOUR_PROJECT_ID/mcp-toolbox-server \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

After deployment, note the service URL (e.g., `https://mcp-toolbox-server-...-uc.a.run.app`).  
You will use this URL in the next step.

### 3. Deploy the ADK agent with Web UI

```bash
cd adk-agent

# Copy the environment template and fill in your project ID and MCP server URL
cp .env.template .env
# Edit .env and set:
#   GOOGLE_CLOUD_PROJECT=YOUR_PROJECT_ID
#   MCP_SERVER_URL=https://mcp-toolbox-server-...-uc.a.run.app

# Deploy using ADK (this builds and pushes the agent with the UI)
adk deploy cloud_run --with_ui .
```

When prompted, select your region (e.g., `us-central1`).  
The deployment will output a Cloud Run URL (e.g., `https://adk-default-service-name-...-uc.a.run.app`).

### 4. Test the agent

Open the Cloud Run URL in a browser.  
Select the agent `devops_failure_analyzer` from the dropdown.  
Type a question, for example:

```
Show me the last 3 failed pipelines
```

The agent will call the MCP Toolbox server, query BigQuery, and return a structured answer with pipeline IDs, root causes, categories, and suggested fixes.

<img width="1864" height="910" alt="msedge_DfwnFIZUBQ" src="https://github.com/user-attachments/assets/46babe40-fb6f-4585-92d3-d3f5d9c16026" />


## Clean Up

To avoid ongoing charges, delete the Cloud Run services and the BigQuery dataset:

```bash
gcloud run services delete adk-default-service-name --region us-central1
gcloud run services delete mcp-toolbox-server --region us-central1
bq rm -r -f YOUR_PROJECT_ID:devops
```

## Using Vertex AI (no API key)

The agent uses **Vertex AI** by default (as set in `.env.template`).  
Make sure the Cloud Run service account has the role `roles/aiplatform.user`.  
This role is often automatically assigned by the `adk deploy` command; if not, you can add it manually:

```bash
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:YOUR_PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
  --role="roles/aiplatform.user"
```

## License

Apache 2.0
```
