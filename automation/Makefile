# ============================================================================
# Makefile — Automação de Demo & Implantação (Projeto GCP: gemini-demo-qi)
# Gemini Enterprise App: alisson-demo_1792679266221 (location: global)
# ============================================================================
PROJECT_ID ?= gemini-demo-qi
REGION ?= us-central1
GE_LOCATION ?= global
GE_ENGINE_ID ?= alisson-demo_1792679266221
GITHUB_REPO ?= https://github.com/neochaotic/data-ai-presales.git
AGENTS_DIR := ../agents

.PHONY: help check-env init-gcp provision-retail-gcp seed-analytics-bq install-python run-ui-python run-cli-python run-agent-go deploy-agent-engine open-consoles publish-github

help:
	@echo "======================================================================"
	@echo " 🛒 QI Network — Data & AI Pre-Sales Automation"
	@echo "    Projeto GCP:        $(PROJECT_ID)"
	@echo "    Gemini Enterprise:  $(GE_ENGINE_ID) ($(GE_LOCATION))"
	@echo "======================================================================"
	@echo "Comandos disponíveis:"
	@echo "  make provision-retail-gcp  -> Cria Bucket GCS + Manual Varejo + Tabela operacional para $(GE_ENGINE_ID)"
	@echo "  make seed-analytics-bq     -> Gera 5.000 vendas históricas + Estoque no BigQuery para Conversational Analytics"
	@echo "  make install-python        -> Instala o google-adk e dependências Python em virtualenv"
	@echo "  make run-agent-go          -> Inicia o Microsserviço/Agente ADK de Varejo em Go (porta 8081)"
	@echo "  make run-ui-python         -> Inicia a UI Visual do ADK (adk web) na porta 8000"
	@echo "  make run-cli-python        -> Executa o Orquestrador Multi-Agente no terminal (adk run)"
	@echo "  make deploy-agent-engine   -> Faz o deploy do Agente para o Vertex AI Agent Engine"
	@echo "  make open-consoles         -> Exibe os links diretos do seu App Gemini Enterprise, BigQuery e ADK"
	@echo "  make publish-github        -> Faz commit e push de todo o kit para $(GITHUB_REPO)"

check-env:
	@echo "🔍 Verificando configuração do gcloud para o projeto $(PROJECT_ID)..."
	gcloud config set project $(PROJECT_ID)
	@echo "✅ Projeto ativo: $(PROJECT_ID) | Região: $(REGION) | Gemini Enterprise: $(GE_ENGINE_ID)"

init-gcp:
	bash ./setup-gemini-demo-qi.sh $(PROJECT_ID) $(REGION)

provision-retail-gcp:
	bash ./provision-retail-demo-gcloud.sh $(PROJECT_ID) $(REGION) $(GE_ENGINE_ID)

seed-analytics-bq:
	bash ./seed-bigquery-analytics-gcloud.sh $(PROJECT_ID) $(REGION)

install-python:
	python3 -m venv .venv
	./.venv/bin/pip install --upgrade pip
	./.venv/bin/pip install -r $(AGENTS_DIR)/python_orchestrator/requirements.txt
	@echo "✅ Ambiente Python ADK instalado em automation/.venv"

run-agent-go:
	@echo "⚡ Iniciando Agente de Varejo Omnicanal em Go (porta 8081)..."
	cd $(AGENTS_DIR)/go-microservice-agent && GOOGLE_CLOUD_PROJECT=$(PROJECT_ID) go run main.go

run-ui-python:
	@echo "🖥️  Iniciando ADK Web UI (http://localhost:8000) para exploração visual..."
	cd $(AGENTS_DIR) && \
	GOOGLE_GENAI_USE_VERTEXAI=TRUE \
	GOOGLE_CLOUD_PROJECT=$(PROJECT_ID) \
	GOOGLE_CLOUD_LOCATION=$(REGION) \
	GEMINI_ENTERPRISE_ENGINE_ID=$(GE_ENGINE_ID) \
	adk web --port 8000

run-cli-python:
	@echo "💬 Iniciando Orquestrador ADK no modo interativo CLI..."
	cd $(AGENTS_DIR) && \
	GOOGLE_GENAI_USE_VERTEXAI=TRUE \
	GOOGLE_CLOUD_PROJECT=$(PROJECT_ID) \
	GOOGLE_CLOUD_LOCATION=$(REGION) \
	GEMINI_ENTERPRISE_ENGINE_ID=$(GE_ENGINE_ID) \
	adk run python_orchestrator

deploy-agent-engine:
	@echo "🚀 Fazendo deploy do Orquestrador para o Vertex AI Agent Engine ($(PROJECT_ID))..."
	cd $(AGENTS_DIR) && \
	adk deploy agent_engine \
		--project=$(PROJECT_ID) \
		--region=$(REGION) \
		--display_name="qi-retail-omnicanal-orchestrator" \
		python_orchestrator

publish-github:
	bash ./publish-github.sh $(GITHUB_REPO) main

open-consoles:
	@echo "======================================================================"
	@echo " 🌐 LINKS DIRETOS PARA A SUA DEMO (Projeto: $(PROJECT_ID))"
	@echo "======================================================================"
	@echo "1. SEU APP GEMINI ENTERPRISE:      https://console.cloud.google.com/gemini-enterprise/locations/$(GE_LOCATION)/engines/$(GE_ENGINE_ID)/overview/dashboard?project=$(PROJECT_ID)"
	@echo "2. ADK Visual Web UI (Local):      http://localhost:8000"
	@echo "3. BigQuery (Pedidos Varejo 360):  https://console.cloud.google.com/bigquery?project=$(PROJECT_ID)"
	@echo "4. Vertex AI Agent Engine UI:      https://console.cloud.google.com/vertex-ai/agents/agent-engines?project=$(PROJECT_ID)"
	@echo "5. Vertex AI Model Armor (Sec):    https://console.cloud.google.com/security/model-armor?project=$(PROJECT_ID)"
	@echo "6. Cloud Trace (Agent Telemetry):  https://console.cloud.google.com/traces/list?project=$(PROJECT_ID)"
	@echo "======================================================================"
