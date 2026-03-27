#!/bin/bash
# Run these commands in Cloud Shell to set up the BigQuery dataset and sample data

PROJECT_ID=$(gcloud config get-value project)

echo "Creating dataset devops..."
bq --location=US mk --dataset $PROJECT_ID:devops || echo "Dataset already exists"

echo "Creating table pipeline_logs..."
bq query --location=US --use_legacy_sql=false "
CREATE TABLE IF NOT EXISTS \`$PROJECT_ID.devops.pipeline_logs\` (
  pipeline_id STRING,
  status STRING,
  logs STRING,
  timestamp TIMESTAMP
)"

echo "Inserting sample data..."
bq query --location=US --use_legacy_sql=false "
INSERT INTO \`$PROJECT_ID.devops.pipeline_logs\` (pipeline_id, status, logs, timestamp)
VALUES
('build-101', 'FAILED', 'ERROR: Terraform IAM issue', CURRENT_TIMESTAMP()),
('build-102', 'FAILED', 'ERROR: no space left on device', CURRENT_TIMESTAMP()),
('build-103', 'FAILED', 'ERROR: crashloop backoff', CURRENT_TIMESTAMP())
"

echo "Verifying data..."
bq query --location=US --use_legacy_sql=false "SELECT * FROM \`$PROJECT_ID.devops.pipeline_logs\`"
