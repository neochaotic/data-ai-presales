---
name: deploy-full-demo
description: Executa a implantação ponta a ponta da Demo de Pré-Vendas de Varejo Omnicanal no projeto GCP gemini-demo-qi (BigQuery, Cloud Storage, Data Stores do Gemini Enterprise alisson-demo_1792679266221, Agentes ADK em Python e Go, Vertex AI Agent Engine e push para o GitHub).
---

# Skill: Implantação Completa da Demo (`deploy-full-demo`)

Ative esta skill quando o usuário pedir para **"implementar tudo"**, **"subir a demo completa"**, **"provisionar o ambiente no GCP"** ou **"executar o guia de handoff"**.

## Instruções para o Agente

1. Leia integralmente o arquivo [`AGENT_HANDOFF_INSTRUCTIONS.md`](../../AGENT_HANDOFF_INSTRUCTIONS.md) na raiz do repositório `data-ai-presales`.
2. Execute as **7 Etapas** documentadas em `AGENT_HANDOFF_INSTRUCTIONS.md` na ordem exata:
   - **Etapa 1:** Pre-flight check (`gcloud`, `bq`, `python3`, `go`, `git`) apontando para o projeto `gemini-demo-qi`.
   - **Etapa 2:** Executar `automation/provision-retail-demo-gcloud.sh gemini-demo-qi us-central1 alisson-demo_1792679266221`.
   - **Etapa 3:** Executar `automation/seed-bigquery-analytics-gcloud.sh gemini-demo-qi us-central1` e validar as 5.000 linhas no BigQuery.
   - **Etapa 4:** Criar e importar os Data Stores de Cloud Storage e BigQuery via Discovery Engine API para uso no app `alisson-demo_1792679266221`.
   - **Etapa 5:** Instalar o ambiente Python (`make install-python`), subir o microsserviço do Agente em Go na porta `8081`, testar os endpoints e subir o `adk web` na porta `8000`.
   - **Etapa 6:** Fazer deploy do agente no Vertex AI Agent Engine (`make deploy-agent-engine`).
   - **Etapa 7:** Publicar no GitHub (`make publish-github`) se solicitado pelo usuário.
3. Ao concluir, apresente ao usuário o status de cada item do **Checklist Final de Verificação (Definition of Done)** e os links clicáveis das interfaces.
