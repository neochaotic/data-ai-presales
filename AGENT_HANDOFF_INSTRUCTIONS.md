# 🤖 AGENT HANDOFF & AUTONOMOUS IMPLEMENTATION GUIDE

> **PARA O AGENTE EXECUTOR (AI AGENT SYSTEM PROMPT):**
> Este documento contém a especificação técnica determinística, variáveis de ambiente, arquitetura e comandos passo a passo para que você (Agente de IA) compreenda e implemente **100% do ecossistema de Pré-Vendas Google Cloud (Vertex AI ADK Python/Go + BigQuery Conversational Analytics + Gemini Enterprise)** de ponta a ponta, sem ambiguidades.

---

## 1. Contexto Global e Identificadores Fixos do Ambiente

Antes de executar qualquer comando, utilize rigorosamente estes parâmetros:

| Parâmetro | Valor Oficial | Descrição |
| :--- | :--- | :--- |
| `WORKSPACE_ROOT` | `/home/alisson_qinetwork_com_br/Documents/env-config/data-ai-presales` | Diretório raiz deste projeto |
| `PROJECT_ID` | `gemini-demo-qi` | Projeto Google Cloud (GCP) alvo |
| `REGION` | `us-central1` | Região padrão para Vertex AI, Agent Engine, BigQuery e GCS |
| `GE_LOCATION` | `global` | Localização do App Gemini Enterprise |
| `GE_ENGINE_ID` | `alisson-demo_1792679266221` | ID do Engine/App já criado no Gemini Enterprise |
| `GE_DASHBOARD_URL` | `https://console.cloud.google.com/gemini-enterprise/locations/global/engines/alisson-demo_1792679266221/overview/dashboard?project=gemini-demo-qi` | URL do Console do App Gemini Enterprise |
| `GCS_BUCKET` | `gs://gemini-demo-qi-retail-kb` | Bucket GCS para documentos não-estruturados (Grounding) |
| `BQ_DATASET` | `retail_omnicanal` | Dataset BigQuery contendo as tabelas operacionais e analíticas |
| `GITHUB_REPO` | `https://github.com/neochaotic/data-ai-presales.git` | Repositório GitHub remoto |

---

## 2. Arquitetura do Sistema que Você Está Implementando

O sistema demonstra um cenário de **Varejo Omnicanal** estruturado em 3 Atos:
1. **Ato 1 — Motor Multi-Agente (Vertex AI + ADK Python & Go):**
   * **Orquestrador Python (`agents/python_orchestrator/agent.py`):** Construído com `google-adk` (`gemini-2.5-flash`). Possui 3 subagentes:
     * `bigquery_retail_analyst`: Consulta pedidos (`PED-9082`, `PED-4010`, `PED-7721`) e estoque de lojas físicas no BigQuery.
     * `retail_policy_specialist`: Consulta regras de troca, SLA e alçada no manual de operações do Varejo.
     * `go_retail_pos_engine`: Aciona o microsserviço em Go via HTTP/A2A (`http://localhost:8081/api/v1/evaluate`).
   * **Agente Transacional em Go (`agents/go-microservice-agent/main.go` & `adk_agent_example.go`):** Calcula score de risco em ~1ms, reserva estoque na loja física (*Ship-from-Store*), gera Voucher de 10% de Cashback (`VIP10-PED9082`) para pedidos $\le \text{R\$ } 15.000$ e escala pedidos maiores (`PED-7721` de R\$ 54.000) para aprovação da diretoria no Gemini Enterprise.
2. **Ato 2 — Experiência de Negócio & Analytics (Gemini Enterprise `alisson-demo_1792679266221` + BigQuery Conversational Analytics):**
   * Conecta o manual de políticas no Cloud Storage (`gs://gemini-demo-qi-retail-kb/manual-operacoes-omnicanal-2026.html`) e as tabelas estruturadas no BigQuery (`vendas_historico_analytics` com 5.000 vendas, `estoque_lojas_tempo_real` e `orders_and_inventory_360`).
3. **Ato 3 — Engenharia Assistida por IA (Google Antigravity):**
   * Utiliza as skills em `.agents/skills/presales-customizer/SKILL.md` e `.agents/skills/deploy-full-demo/SKILL.md` para evoluir e implantar a solução.

---

## 3. Roteiro de Execução Passo a Passo (Para o Agente Executar em Ordem)

Execute cada etapa abaixo sequencialmente e valide o código de saída (`exit code 0`) antes de avançar.

### ETAPA 1: Pré-Checagem de Autenticação e Ferramentas (Pre-Flight Check)
Execute no terminal:
```bash
cd /home/alisson_qinetwork_com_br/Documents/env-config/data-ai-presales/automation

# 1.1 Verificar autenticação gcloud e definir projeto
gcloud auth list
gcloud config set project gemini-demo-qi

# 1.2 Verificar binários essenciais
python3 --version
go version
bq version
git --version
```
* **Ação de Recuperação:** Se `gcloud auth list` indicar que não há conta ativa ou o token expirou, solicite ao usuário para rodar `gcloud auth login` e `gcloud auth application-default login`.

---

### ETAPA 2: Provisionar APIs, Bucket GCS, Manual de Políticas e Tabela Operacional no BigQuery
Execute o script automatizado de infraestrutura base:
```bash
cd /home/alisson_qinetwork_com_br/Documents/env-config/data-ai-presales/automation
bash ./provision-retail-demo-gcloud.sh gemini-demo-qi us-central1 alisson-demo_1792679266221
```
**O que este passo garante:**
1. Habilita as APIs `aiplatform`, `discoveryengine`, `bigquery`, `storage`, `cloudtrace`, `logging`, `run`.
2. Cria o bucket `gs://gemini-demo-qi-retail-kb` e faz upload de `manual-operacoes-omnicanal-2026.html`.
3. Cria o dataset `gemini-demo-qi.retail_omnicanal` e a tabela `orders_and_inventory_360` com os pedidos `PED-9082`, `PED-4010` e `PED-7721`.

---

### ETAPA 3: Popular Massa de Dados (5.000 Vendas) para BigQuery Conversational Analytics
Execute o script de geração analítica:
```bash
cd /home/alisson_qinetwork_com_br/Documents/env-config/data-ai-presales/automation
bash ./seed-bigquery-analytics-gcloud.sh gemini-demo-qi us-central1
```
**Validação Obrigatória da Etapa 3:**
```bash
bq --project_id=gemini-demo-qi query --use_legacy_sql=false \
  "SELECT COUNT(*) AS total_vendas, ROUND(SUM(IF(salvo_por_ship_from_store, receita_liquida_brl, 0)), 2) AS receita_salva_ia FROM \`gemini-demo-qi.retail_omnicanal.vendas_historico_analytics\`"
```
* **Critério de Sucesso:** `total_vendas` deve retornar exatamente `5000`.

---

### ETAPA 4: Criar Data Stores via Discovery Engine API para o App Gemini Enterprise (`alisson-demo_1792679266221`)
Para facilitar a conexão no app `alisson-demo_1792679266221`, você pode criar os Data Stores de Cloud Storage e BigQuery diretamente via API REST do Discovery Engine:

```bash
PROJECT_ID="gemini-demo-qi"
TOKEN="$(gcloud auth print-access-token)"

# 4.1 Criar Data Store para o Manual de Varejo no Cloud Storage
curl -X POST \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -H "X-Goog-User-Project: ${PROJECT_ID}" \
  "https://discoveryengine.googleapis.com/v1alpha/projects/${PROJECT_ID}/locations/global/collections/default_collection/dataStores?dataStoreId=qi-retail-manual-gcs-ds" \
  -d '{
    "displayName": "QI Varejo - Manual Operacoes Omnicanal (GCS)",
    "industryVertical": "GENERIC",
    "solutionTypes": ["SOLUTION_TYPE_SEARCH"],
    "contentConfig": "CONTENT_REQUIRED"
  }'

# 4.2 Importar o arquivo HTML do Bucket para o Data Store GCS
curl -X POST \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -H "X-Goog-User-Project: ${PROJECT_ID}" \
  "https://discoveryengine.googleapis.com/v1alpha/projects/${PROJECT_ID}/locations/global/collections/default_collection/dataStores/qi-retail-manual-gcs-ds/branches/0/documents:import" \
  -d '{
    "gcsSource": {
      "inputUris": ["gs://gemini-demo-qi-retail-kb/manual-operacoes-omnicanal-2026.html"],
      "dataSchema": "content"
    }
  }'

# 4.3 Criar Data Store Estruturado para a Tabela de Vendas no BigQuery
curl -X POST \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -H "X-Goog-User-Project: ${PROJECT_ID}" \
  "https://discoveryengine.googleapis.com/v1alpha/projects/${PROJECT_ID}/locations/global/collections/default_collection/dataStores?dataStoreId=qi-retail-vendas-bq-ds" \
  -d '{
    "displayName": "QI Varejo - Vendas e Estoque 360 (BigQuery)",
    "industryVertical": "GENERIC",
    "solutionTypes": ["SOLUTION_TYPE_SEARCH"],
    "contentConfig": "NO_CONTENT"
  }'

# 4.4 Importar a tabela do BigQuery para o Data Store Estruturado
curl -X POST \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -H "X-Goog-User-Project: ${PROJECT_ID}" \
  "https://discoveryengine.googleapis.com/v1alpha/projects/${PROJECT_ID}/locations/global/collections/default_collection/dataStores/qi-retail-vendas-bq-ds/branches/0/documents:import" \
  -d '{
    "bigquerySource": {
      "projectId": "gemini-demo-qi",
      "datasetId": "retail_omnicanal",
      "tableId": "orders_and_inventory_360",
      "dataSchema": "custom"
    }
  }'
```

---

### ETAPA 5: Instalar Dependências Python, Subir o Agente Go e Testar Localmente (`adk web`)

```bash
cd /home/alisson_qinetwork_com_br/Documents/env-config/data-ai-presales/automation

# 5.1 Instalar ambiente virtual Python com google-adk
make install-python

# 5.2 Iniciar o Microsserviço do Agente em Go na porta 8081 (em background)
cd /home/alisson_qinetwork_com_br/Documents/env-config/data-ai-presales/agents/go-microservice-agent
GOOGLE_CLOUD_PROJECT=gemini-demo-qi nohup go run main.go > /tmp/go-retail-agent.log 2>&1 &

# 5.3 Validar Healthcheck e Cálculo Transacional do Agente em Go
sleep 2
curl -s http://localhost:8081/healthz
curl -s -X POST http://localhost:8081/api/v1/evaluate \
  -H "Content-Type: application/json" \
  -d '{"order_id":"PED-9082","customer_id":"CLI-MARINA-9082","amount_brl":6490.0,"operation_type":"SHIP_FROM_STORE_COM_VOUCHER","store_origin":"Loja Shopping Ibirapuera","payment_score":99.0}'

# 5.4 Iniciar a UI Visual do ADK (adk web) na porta 8000
cd /home/alisson_qinetwork_com_br/Documents/env-config/data-ai-presales/agents
GOOGLE_GENAI_USE_VERTEXAI=TRUE \
GOOGLE_CLOUD_PROJECT=gemini-demo-qi \
GOOGLE_CLOUD_LOCATION=us-central1 \
../automation/.venv/bin/adk web --port 8000
```

---

### ETAPA 6: Deploy do Orquestrador no Vertex AI Agent Engine (Produção Serverless)
Quando o ambiente local estiver validado, faça o deploy para o runtime gerenciado do **Vertex AI Agent Engine**:

```bash
cd /home/alisson_qinetwork_com_br/Documents/env-config/data-ai-presales/agents
../automation/.venv/bin/adk deploy agent_engine \
  --project=gemini-demo-qi \
  --region=us-central1 \
  --display_name="qi-retail-omnicanal-orchestrator" \
  python_orchestrator
```
* Após o deploy terminar, copie o `ReasoningEngine / AgentEngine Resource Name` retornado e vincule-o na aba **Agents** do app Gemini Enterprise (`alisson-demo_1792679266221`).

---

### ETAPA 7: Versionar e Publicar no GitHub (`neochaotic/data-ai-presales`)
```bash
cd /home/alisson_qinetwork_com_br/Documents/env-config/data-ai-presales/automation
bash ./publish-github.sh https://github.com/neochaotic/data-ai-presales.git main
```

---

## 4. Checklist Final de Verificação do Agente (Definition of Done)

Antes de reportar conclusão ao usuário, verifique se todos os itens abaixo são verdadeiros:
- [ ] Bucket `gs://gemini-demo-qi-retail-kb/manual-operacoes-omnicanal-2026.html` existe e está acessível.
- [ ] Tabelas `orders_and_inventory_360`, `vendas_historico_analytics` (5.000 linhas) e `estoque_lojas_tempo_real` existem em `gemini-demo-qi.retail_omnicanal`.
- [ ] Agente em Go responde `{"status":"UP"}` em `http://localhost:8081/healthz` e retorna `AUTO_APPROVED_BY_GO_ADK_AGENT` para `PED-9082` e `ESCALATE_TO_DIRECTOR_IN_GEMINI_ENTERPRISE` para `PED-7721`.
- [ ] UI do `adk web` carrega o grafo do `qi_enterprise_orchestrator` em `http://localhost:8000`.
- [ ] Código-fonte e documentação sincronizados no repositório GitHub `https://github.com/neochaotic/data-ai-presales`.
