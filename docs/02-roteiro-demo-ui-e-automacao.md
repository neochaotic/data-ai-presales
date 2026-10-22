# 🖥️ Roteiro de Demo: Equilíbrio entre Automação (CLI) e Exploração Visual (UI)

Em uma demo de Pré-Vendas, mostrar apenas tela preta de terminal afasta executivos de negócio, mas clicar manualmente em dezenas de telas de configuração toma tempo e gera risco de erro ao vivo.

Este guia aplica a estratégia **"Automatize o Setup nos Bastidores, Explore o Valor Visual na UI"**, configurada para o projeto GCP **`gemini-demo-qi`**.

---

## ⏱️ Cronograma Sugerido de Demo (45 Minutos)

| Tempo | Bloco | Onde Mostrar (UI Principal) | O que Roda Automatizado (CLI/Background) | Público-Alvo Principal |
| :--- | :--- | :--- | :--- | :--- |
| **00-08m** | **Visão & Posicionamento** | Diagrama dos 3 Atos (Vertex -> Gemini Enterprise -> Antigravity) | Ambiente já inicializado via `make init-gcp` | C-Level, Diretores, TI + Negócios |
| **08-20m** | **Ato 2: O Palco do Usuário (Gemini Enterprise)** | **UI do Gemini Enterprise** (Busca Unificada, Conectores, Agent Gallery, No-Code Designer) | Conector BigQuery / Cloud Storage alimentado via script | Diretores de Negócio, Operações, RH, Finanças |
| **20-35m** | **Ato 1: O Motor Multi-Agente (Vertex AI + ADK Python/Go)** | **UI do `adk web`** (Grafo Visual de Agentes e Eventos) + **Console GCP (Vertex AI Agent Engine & Traces)** | `make run-ui-python`, `make run-agent-go` e `make deploy-agent-engine` | Arquitetos, Engenheiros de Dados/IA, CTO |
| **35-45m** | **Ato 3: A Fábrica 10x (Google Antigravity)** | **UI do Antigravity IDE / App 2.0** (Chat Canvas, Subagentes, Diff Visual, Skills) | Skill `.agents/skills/presales-customizer` adaptando o código ao vivo | CTO, Gerentes de Engenharia, Tech Leads |

---

## 🎬 Passo a Passo Detalhado da Demonstração

### Pré-Reunião (5 minutos antes da call — 100% Automatizado)

No seu terminal, dentro da pasta `automation/`, execute:

```bash
# 1. Garante projeto gemini-demo-qi configurado e autenticado
make check-env PROJECT_ID=gemini-demo-qi

# 2. Sobe o microsserviço do Agente em Go (porta 8081) em background
make run-agent-go &

# 3. Sobe a interface visual do ADK Web (porta 8000)
make run-ui-python
```

Deixe 4 abas abertas no seu navegador:
1. **Aba 1 (Seu App Gemini Enterprise — `alisson-demo_1792679266221`):**
   `https://console.cloud.google.com/gemini-enterprise/locations/global/engines/alisson-demo_1792679266221/overview/dashboard?project=gemini-demo-qi`
2. **Aba 2 (ADK Visual Web UI):** `http://localhost:8000` (Interface visual interativa do Agent Development Kit).
3. **Aba 3 (Vertex AI Agent Engine Console):** `https://console.cloud.google.com/vertex-ai/agents/agent-engines?project=gemini-demo-qi`
4. **Aba 4 (Google Antigravity):** Janela do Antigravity IDE ou Antigravity 2.0 aberta neste repositório.

---

### Bloco 1: Explorando a UI do **Gemini Enterprise** (O Valor para o Negócio)

1. **Na Aba 1 (Web App do Gemini Enterprise):**
   * Mostre a **Barra de Pesquisa Unificada**: Faça uma pergunta complexa que cruza documentos (PDFs de políticas corporativas) e dados estruturados.
   * *Exemplo de Prompt:* `"Qual é a nossa política atual de SLA para clientes Enterprise e quais pedidos críticos estão em risco hoje?"`
   * **Destaque Visual na UI:**
     * Aponte para as **Citações Clicáveis (Grounding)** no rodapé da resposta — mostre como o cliente pode auditar exatamente de qual página do PDF ou tabela do BigQuery veio a informação.
     * Abra o menu lateral **"Data Sources / Conectores"** no Console para mostrar a lista visual de conectores nativos (SharePoint, Jira, ServiceNow, Salesforce, SAP, BigQuery) e explique que o **controle de acesso (ACL)** é herdado automaticamente.
2. **Transição para Agentes Customizados:**
   * Clique na aba **"Agents" (Galeria de Agentes)** dentro do Gemini Enterprise.
   * Mostre que, além dos agentes prontos do Google (Deep Research, NotebookLM Enterprise) e dos agentes criados sem código pelo usuário (*No-Code Designer*), existe ali o **"Orquestrador Corporativo QI (Vertex ADK)"**.
   * Diga: *"Agora vou mostrar como construímos esse agente transacional nos bastidores usando o novo Vertex AI e o ADK em Python e Go."*

---

### Bloco 2: Explorando a UI do **ADK Web** e **Vertex AI Agent Engine** (A Engenharia em Python & Go)

1. **Na Aba 2 (`http://localhost:8000` — ADK Web UI):**
   * Selecione o agente `qi_enterprise_orchestrator` no menu superior esquerdo.
   * **O que explorar na UI do `adk web`:**
     * Clique na aba **"Graph" / "Architecture"** no painel lateral do ADK Web: O cliente verá visualmente a árvore hierárquica do `RootOrchestrator` conectado a 3 subagentes/ferramentas:
       1. `KnowledgeSpecialist` (Grounding & Políticas)
       2. `DataAnalystAgent` (BigQuery / Métricas Analíticas em Python)
       3. `GoTransactionalEngine` (Agente/Microsserviço em **Go** via protocolo HTTP/A2A para cálculo de risco/SLA e execução transacional em sub-milissegundos).
   * Envie um comando no chat do `adk web`:
     * `"Analise o cliente ID CUST-9082, verifique no BigQuery o histórico recente, calcule o score de risco operacional no motor em Go e gere o protocolo de aprovação."`
   * **Momento "Uau" na UI:**
     * Clique na aba **"Events" / "Trace"** na esquerda da tela do `adk web`.
     * Mostre ao cliente a linha do tempo visual: quando o Orquestrador Python delegou para o Analista de Dados, o JSON exato enviado para o **Agente em Go**, o retorno em poucos milissegundos e a resposta consolidada!

2. **Na Aba 3 (Console GCP — Vertex AI Agent Engine em `gemini-demo-qi`):**
   * Mostre que esse código não fica preso na máquina do desenvolvedor. Com um único comando (`make deploy-agent-engine`), ele sobe para o **Vertex AI Agent Engine**.
   * **O que explorar na UI do GCP Console:**
     * **Sessions & Memory Bank:** Mostre onde o Agent Engine persiste o histórico de sessão sem que o time precise configurar bancos Redis/Postgres manualmente.
     * **Tracing & Observability (Cloud Trace):** Clique em uma requisição recente para mostrar o gráfico de cascata (Waterfall) de latência e consumo de tokens de cada etapa do agente.
     * **Model Armor & Evaluation:** Aponte no menu lateral o *Model Armor* (filtros de segurança corporativa, bloqueio de dados sensíveis PII/CPF/Cartão) e o *GenAI Evaluation Service*.

---

### Bloco 3: Explorando a UI do **Google Antigravity** (A Fábrica 10x ao Vivo)

1. **Na Aba 4 (Google Antigravity IDE ou App 2.0):**
   * Pergunte ao cliente na reunião: *"Me dê uma regra de negócio específica da sua empresa ou do seu setor que não está nesse agente hoje."* (Ex: *"Precisamos bloquear aprovações acima de R$ 50.000 se o cliente tiver pendência cadastral"*).
   * **O que mostrar na UI do Antigravity:**
     * No **Chat Canvas**, use `@` para referenciar os arquivos `@agents/python-orchestrator/agent.py` e `@agents/go-microservice-agent/main.go` ou invoque a skill do projeto.
     * Mostre a divisão de trabalho: o Antigravity lê o código em Python e Go simultaneamente, propõe um **Diff Visual (verde/vermelho)** diretamente no editor, executa os testes no **Terminal Sandbox** sem comprometer a máquina e atualiza instantaneamente a UI do `adk web`!
     * Abra o **Painel Auxiliar (Subagents / Background Tasks / Artifacts)** do Antigravity 2.0 para mostrar como múltiplos agentes de engenharia trabalham em paralelo para documentar, testar e codificar.
