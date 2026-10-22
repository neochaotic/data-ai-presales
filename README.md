# 🚀 Data & AI Pre-Sales Kit — Google Cloud (`gemini-demo-qi`)

Bem-vindo ao repositório oficial de **Pré-Vendas de Data & AI** da **QI Network** no projeto GCP **`gemini-demo-qi`** ([neochaotic/data-ai-presales](https://github.com/neochaotic/data-ai-presales)).

Este README foi desenhado como seu **Painel de Comando da Apresentação (Cheat Sheet)**. Você não precisa procurar em várias pastas durante a reunião: **o roteiro minuto a minuto, as abas que você deve abrir, o que falar e as perguntas exatas para copiar e colar estão logo abaixo!**

---

## 🖥️ 1. As 4 Abas que Você Deve Deixar Abertas Antes da Reunião

| Aba | O que abrir no Navegador | Para que serve na Demo |
| :--- | :--- | :--- |
| **Aba 1** | **[App Gemini Enterprise (`alisson-demo`)](https://console.cloud.google.com/gemini-enterprise/locations/global/engines/alisson-demo_1792679266221/overview/dashboard?project=gemini-demo-qi)** | **Ato 1 (Negócios & Governança):** Mostrar busca com Grounding no Manual de Operações (GCS) + Tabelas do BigQuery + Prática Visual No-Code de Agent Builder. |
| **Aba 2** | **[BigQuery Studio (`gemini-demo-qi`)](https://console.cloud.google.com/bigquery?project=gemini-demo-qi)** | **Ato 1.5 (Conversational Analytics):** Conversar em Português com a tabela de **5.000 vendas** (`retail_omnicanal.vendas_historico_analytics`) e gerar gráficos executivos na hora. |
| **Aba 3** | **[ADK Web Dev UI (`http://localhost:8000`)](http://localhost:8000/dev-ui/)** *(ou [Vertex AI Agent Engine](https://console.cloud.google.com/vertex-ai/reasoning-engines?project=gemini-demo-qi))* | **Ato 2 (Engenharia Multi-Agente Python + Go):** Mostrar o grafo visual de 3 agentes resolvendo uma ruptura de estoque e acionando o motor Go em **0.12 ms**. |
| **Aba 4** | **Google Antigravity IDE / App 2.0** *(neste repositório)* | **Ato 3 (Fábrica de Software 10x):** Mudar uma regra de Black Friday ao vivo em Python e Go simultaneamente com Diff Visual em menos de 1 minuto. |

> 💡 **Comando rápido caso precise reiniciar os serviços locais (Aba 3) antes da call:**
> ```bash
> cd /home/alisson_qinetwork_com_br/Documents/env-config/data-ai-presales/automation
> make run-agent-go &
> make run-ui-python
> ```

---

## 🎤 2. Roteiro Passo a Passo: Como Conduzir a Apresentação + Perguntas Prontas

Usamos **Varejo Omnicanal** como história principal porque **qualquer executivo na sala (seja de Banco, Saúde, Indústria ou Varejo) é consumidor** e entende imediatamente o problema de um pedido atrasado ou uma dúvida de troca na loja.

---

### 🎬 ATO 1: O Palco do Usuário de Negócio — Gemini Enterprise & Agent Builder Visual (10 min)
**Onde mostrar:** **Aba 1** (Gemini Enterprise `alisson-demo_1792679266221`).

1. **O discurso (30s):**
   > *"Muitas empresas têm dezenas de PDFs de políticas no Cloud Storage e tabelas no BigQuery, mas o vendedor na ponta ou o analista de operações não consegue cruzar isso rápido. Aqui no Gemini Enterprise, já conectamos o nosso Manual Oficial de Operações de Varejo 2026 (`retail-politicas-kb`) e nossa base de pedidos no BigQuery (`retail-vendas-bq-ds`)."*

2. **Pergunta 1 — Grounding em Documentos com Citação Auditável (Copiar e Colar no Preview/Web App):**
   ```text
   Qual é a política oficial de troca para produtos com caixa aberta após 7 dias? Clientes VIP Ouro e Diamante possuem alguma exceção?
   ```
   * **O que apontar na tela:** Mostre que ele responde exatamente a regra de **30 dias para clientes Ouro/Diamante mesmo com caixa aberta** e exibe a **citação clicável** do documento `manual-operacoes-omnicanal-2026.html` no Cloud Storage.

3. **Pergunta 2 — Cruzando Regra do Manual + Dados Estruturados:**
   ```text
   Qual é a alçada máxima em Reais para aprovação automática pelo Agente em Go sem precisar escalar para a Diretoria no Gemini Enterprise?
   ```
   * **O que apontar na tela:** O limite de **R$ 15.000,00** e score de risco inferior a `0.45`.

4. **Prática Rápida de Agent Builder (No-Code em 60 segundos — Custo Zero):**
   * No menu lateral do Gemini Enterprise, clique em **Agents** $\rightarrow$ **Create Agent (No-Code Designer)**.
   * Mostre que um analista de negócios pode criar um assistente sem programar nada, apenas colando a instrução:
     ```text
     Você é o Concierge de Atendimento de Loja da QI Network. Use o Data Store retail-politicas-kb para tirar dúvidas de trocas e o retail-vendas-bq-ds para consultar pedidos.
     ```
   * Marque os Data Stores `retail-politicas-kb` e `retail-vendas-bq-ds` que já estão prontos na lista!

---

### 📊 ATO 1.5: Conversational Analytics no BigQuery — "Conversando com 5.000 Vendas" (10 min)
**Onde mostrar:** **Aba 2** ([BigQuery Studio](https://console.cloud.google.com/bigquery?project=gemini-demo-qi) $\rightarrow$ Dataset `retail_omnicanal` $\rightarrow$ Tabela `vendas_historico_analytics` $\rightarrow$ botão **Ask Gemini / Conversational Analytics**).

1. **O discurso (30s):**
   > *"Para o C-Level (CFO, Diretor Comercial), não basta buscar documentos: ele quer conversar com os dados reais no BigQuery em linguagem natural, sem depender da fila de BI para criar dashboards."*

2. **Pergunta 1 — O "Momento Uau" de ROI para o CFO (Copiar e Colar):**
   ```text
   Quantos pedidos sofreram ruptura no CD Central e quanto de receita líquida em Reais nós conseguimos salvar graças ao redirecionamento Ship-from-Store dos agentes?
   ```
   * **Resultado esperado:** Mostra que ~80% dos pedidos com falta de estoque no CD foram salvos pelas lojas físicas, recuperando **mais de R$ 2,5 milhões em receita líquida**!

3. **Pergunta 2 — Gráfico de Receita e Margem por Categoria (Copiar e Colar):**
   ```text
   Qual é a receita líquida total e a margem de lucro por categoria de produto nos últimos 12 meses? Ordene da maior para a menor.
   ```

4. **Pergunta 3 — Posição de Estoque em Tempo Real (`estoque_lojas_tempo_real`):**
   ```text
   Quais produtos estão com status CRITICO_RUPTURA ou ALERTA_BAIXO_ESTOQUE nos nossos Centros de Distribuição hoje, e quais lojas físicas têm estoque saudável desses mesmos produtos para cobrir a demanda?
   ```
   *(Mostra na hora que o CD de Cajamar zerou a Smart TV 65" OLED, mas a Loja do Shopping Ibirapuera tem 14 unidades prontas para envio!).*

---

### ⚙️ ATO 2: O Motor Multi-Agente — Vertex AI ADK (Python + Go em Sub-milissegundo) (15 min)
**Onde mostrar:** **Aba 3** (`http://localhost:8000/dev-ui/` selecionando o agente `python_orchestrator` / `qi_enterprise_orchestrator`).

1. **O discurso (30s):**
   > *"Quando o problema exige ação transacional em múltiplos sistemas (consultar banco de dados, validar regra de compliance e reservar estoque no ERP em milissegundos durante uma Black Friday), usamos o **Google Agent Development Kit (ADK)** rodando no **Vertex AI Agent Engine**. Aqui combinamos o melhor de dois mundos: **Python** para orquestração cognitiva e **Go (Golang)** para cálculo de risco e transação de baixíssima latência."*

2. **O que mostrar antes de digitar:**
   * Aponte para o **Grafo Visual de Agentes** na tela do `adk web`: mostre o `qi_enterprise_orchestrator` conectado aos 3 especialistas (`bigquery_retail_analyst`, `retail_policy_specialist` e `go_retail_pos_engine`).

3. **Prompt 1 — Caso de Sucesso: Salvar a Venda da Cliente VIP em 0.12ms (Copiar e Colar):**
   ```text
   O pedido PED-9082 da cliente Marina está atrasado por ruptura no CD. Consulte os dados no BigQuery, verifique a política de varejo e acione o agente em Go para resolver com envio da loja mais próxima e voucher.
   ```
   * **O que acontece ao vivo na tela:**
     1. O `bigquery_retail_analyst` consulta o pedido `PED-9082` (Marina Silva, Cliente Diamante VIP, Smart TV 65" OLED de R$ 6.490) e acha 4 unidades na **Loja Shopping Ibirapuera (a 3,2 km)**.
     2. O `retail_policy_specialist` valida que cliente Diamante tem direito a **Ship-from-Store Express (2h) + 10% de Cashback**.
     3. O `go_retail_pos_engine` chama o microsserviço em Go na porta `8081` e **aprova automaticamente em ~0.12 ms**, gerando o voucher **`VIP10-PED9082` (R$ 649,00 de cashback)** e a mensagem pronta de WhatsApp para a cliente!

4. **Prompt 2 — Caso de Governança e Trava de Alçada (Pedido B2B de R$ 54.000):**
   ```text
   Analise o pedido corporativo PED-7721 (Lote de 15 Ar-Condicionados de R$ 54.000) que pediu estorno total e tente aprovar no motor em Go.
   ```
   * **O que apontar na tela:** O Agente em Go **bloqueia a aprovação automática** (`ESCALATE_TO_DIRECTOR_IN_GEMINI_ENTERPRISE`) porque R$ 54.000 ultrapassa a alçada de R$ 15.000, exigindo aprovação humana do Diretor!

---

### 🚀 ATO 3: A Fábrica de Software 10x — Google Antigravity Ao Vivo (10 min)
**Onde mostrar:** **Aba 4** (Google Antigravity IDE / App 2.0).

1. **O discurso (30s):**
   > *"Como a sua equipe de engenharia constrói e mantém tudo isso 10x mais rápido? Com o **Google Antigravity**. Imagine que chegou a sexta-feira da Black Friday e a diretoria decidiu subir o cashback de 10% para 15% e a alçada automática de R$ 15.000 para R$ 25.000 agora."*

2. **Prompt para digitar no Chat do Antigravity (Copiar e Colar):**
   ```text
   Estamos em campanha de Black Friday: atualize a política em @agents/python_orchestrator/agent.py e o cálculo no motor em Go em @agents/go-microservice-agent/main.go para aumentar o cashback automático de 10% para 15% e o limite de alçada de R$ 15.000 para R$ 25.000.
   ```
   * **Resultado Visual:** O cliente vê o Antigravity alterar **Python e Go simultaneamente** com Diff Visual e testar tudo no terminal integrado em segundos!

---

## 🔄 3. "Ponte de Tradução": Como Conectar Essa Demo ao Setor do Seu Cliente

Ao finalizar a demo, use esta frase de 15 segundos conforme o setor do cliente na reunião:
* 🏦 **Bancos e Seguradoras:** *"Viu como o agente cruzou o pedido `#PED-9082` no BigQuery, leu a regra no manual e aprovou na alçada em Go até R$ 15 mil? No seu banco, troque 'Pedido com Ruptura' por **'Análise de Sinistro, Crédito ou Disputa de PIX'** — o motor é exatamente o mesmo."*
* 🏥 **Saúde / Hospitais / Planos:** *"No seu cenário, troque 'Pedido Atrasado' por **'Autorização de Guia Médica (TISS)'**: o Python checa a carência no banco, lê o protocolo da ANS no PDF e o Go libera a senha em 1 milissegundo."*
* 🏭 **Indústria e Logística:** *"Na sua operação, troque a 'Loja Física mais próxima' por **'Galpão Regional ou Fornecedor Homologado'** quando falta insumo crítico na linha de produção."*

---

## 📚 4. Índice Completo da Documentação Detalhada (Na pasta `docs/`)

Se você quiser aprofundar em qualquer tópico específico ou enviar material comercial após a call, todos os documentos detalhados estão na pasta [`docs/`](docs/):

1. 📖 **[`docs/01-storytelling-playbook.md`](docs/01-storytelling-playbook.md)**: Narrativa executiva completa dos 3 Atos, dores de C-Level e arquitetura detalhada.
2. 🖥️ **[`docs/02-roteiro-demo-ui-e-automacao.md`](docs/02-roteiro-demo-ui-e-automacao.md)**: Cronograma de 45 minutos dividindo o que rodar no terminal vs. o que clicar nas telas.
3. 📄 **[`docs/03-template-proposta-e-implantacao.md`](docs/03-template-proposta-e-implantacao.md)**: Template pronto de Proposta Comercial (3 fases: Discovery, MVP, Escala) + Checklist técnico de entrega.
4. 🛒 **[`docs/04-casos-varejo-e-proposta.md`](docs/04-casos-varejo-e-proposta.md)**: Detalhamento dos 3 casos de Varejo Omnicanal (`PED-9082`, `PED-4010`, `PED-7721`) e ROI esperado.
5. 📊 **[`docs/05-guia-conversational-analytics-e-bigquery.md`](docs/05-guia-conversational-analytics-e-bigquery.md)**: Guia específico dos 7 prompts executivos para o BigQuery Conversational Analytics e conector do Gemini Enterprise.
6. 🤖 **[`AGENT_HANDOFF_INSTRUCTIONS.md`](AGENT_HANDOFF_INSTRUCTIONS.md)**: Runbook técnico determinístico para que qualquer outro Agente de IA recrie todo o ambiente sozinho do zero.

---

## 🛡️ 5. Diretrizes de FinOps e Governança de Custos (Restrições Explícitas)

Este repositório e todas as automações foram desenhados com princípios rígidos de **FinOps e Custo Zero/Quase Nulo** (regra ativa em [`.geminirules`](.geminirules)):

- **Proibido provisionar recursos dedicados 24/7**:
  - ❌ **Sem Vertex AI Vector Search Index Endpoints** (evita custos contínuos de máquinas dedicadas).
  - ❌ **Sem Vertex AI Model Serving Endpoints** em VMs dedicadas.
  - ❌ **Sem BigQuery BI Engine Reservations** ou compra de capacidade de slots fixos.
  - ❌ **Sem Clusters GKE ou VMs Compute Engine** persistentes.
- **Arquitetura 100% Serverless & On-Demand**:
  - ✅ **Vertex AI Agent Engine (Reasoning Engine)** & **Agent Builder**: Serverless gerenciado, cobra apenas centavos por chamada executada (coberto pelo free tier).
  - ✅ **BigQuery On-Demand**: Dados sintéticos leves (< 2 MB), dentro do limite gratuito mensal do Google Cloud (10 GB storage / 1 TB queries).
  - ✅ **Cloud Storage Standard**: 1 arquivo HTML (< 3 KB), custo < R$ 0,01.
  - ✅ **Execução Híbrida/Local**: Agentes transacionais de alta concorrência (Go) e Dev UI (ADK) rodam localmente no workspace (`localhost:8081` e `localhost:8000`).
