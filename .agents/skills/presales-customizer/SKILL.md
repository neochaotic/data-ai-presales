---
name: presales-customizer
description: Adapta instantaneamente os agentes ADK (Python e Go), os dados simulados e o template de Proposta Comercial do projeto gemini-demo-qi para o setor e dores específicas de um cliente antes ou durante uma reunião de Pré-Vendas.
---

# Skill: Customizador de Demo & Proposta de Pré-Vendas (`presales-customizer`)

Use esta skill sempre que o usuário pedir para adaptar a demo ou a proposta comercial para um cliente específico (ex: Varejo, Bancos/FSI, Saúde, Manufatura, Logística, Agro, etc.).

## Passo a Passo de Execução

1. **Identificar Perfil do Cliente:**
   - Nome do Cliente (`CLIENTE`)
   - Setor / Vertical (`VERTICAL`: Varejo, Financeiro, Saúde, Indústria, etc.)
   - Dor Principal (`CENARIO`: Atendimento, Backoffice, Risco/Fraude, Operações, Gestão do Conhecimento)

2. **Customizar o Orquestrador ADK em Python (`agents/python_orchestrator/agent.py`):**
   - Atualize o dicionário `policies_db` em `search_enterprise_policies` e `mock_catalog` em `query_bigquery_customer_360` com exemplos realistas da vertical do cliente.
   - Ajuste a instrução do `root_agent` mencionando o contexto do cliente para que, ao abrir a UI do `adk web`, o agente já responda como um especialista daquela empresa.

3. **Customizar o Agente em Go (`agents/go-microservice-agent/main.go`):**
   - Ajuste a regra de cálculo ou nomenclatura de decisão em `evaluateHandler` caso o cliente tenha uma regra específica de alçada ou SLA discutida na reunião.

4. **Gerar Proposta Comercial Sob Medida (`docs/proposta-customizada-<cliente>.md`):**
   - Copie a estrutura de `docs/03-template-proposta-e-implantacao.md` e preencha todos os campos `[COLCHETES]` com os casos de uso, arquitetura e entregáveis voltados para o `CLIENTE`.
