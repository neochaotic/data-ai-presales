#!/usr/bin/env bash
# ============================================================================
# Bootstrap Automatizado do Projeto GCP para Pré-Vendas & Implantação
# Projeto Padrão: gemini-demo-qi
# ============================================================================
set -euo pipefail

PROJECT_ID="${1:-gemini-demo-qi}"
REGION="${2:-us-central1}"

echo "🚀 Configurando projeto GCP '${PROJECT_ID}' na região '${REGION}'..."

gcloud config set project "${PROJECT_ID}"

echo "📦 Habilitando APIs essenciais (Vertex AI, Agent Engine, Gemini Enterprise/Discovery Engine, BigQuery, Cloud Trace)..."
gcloud services enable \
  aiplatform.googleapis.com \
  discoveryengine.googleapis.com \
  bigquery.googleapis.com \
  storage.googleapis.com \
  cloudtrace.googleapis.com \
  logging.googleapis.com \
  run.googleapis.com \
  --project="${PROJECT_ID}"

echo "✅ APIs habilitadas com sucesso no projeto ${PROJECT_ID}!"
echo ""
echo "Próximos passos para a Demo:"
echo "  1. Execute 'make run-agent-go &' para subir o Agente em Go"
echo "  2. Execute 'make run-ui-python' para abrir a UI visual do ADK em http://localhost:8000"
echo "  3. Execute 'make open-consoles' para abrir as telas do Vertex AI e Gemini Enterprise"
