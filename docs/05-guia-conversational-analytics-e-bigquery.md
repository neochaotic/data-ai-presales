# 📊 Guia Prático: Demo de Conversational Analytics & Conector BigQuery

Para impressionar clientes em uma demo de **Conversational Analytics (BigQuery Data Agent)** e do **Conector BigQuery no Gemini Enterprise (`alisson-demo_1792679266221`)**, não basta uma tabela com 3 linhas: você precisa de **volume estatístico** (milhares de linhas), **histórico temporal** (para gráficos de tendência) e **metadados semânticos nas colunas** (`OPTIONS(description=...)`).

O script [`automation/seed-bigquery-analytics-gcloud.sh`](file:///home/alisson_qinetwork_com_br/Documents/env-config/data-ai-presales/automation/seed-bigquery-analytics-gcloud.sh) cria exatamente essa estrutura no projeto **`gemini-demo-qi`**.

---

## ⚡ Passo 1: Gerar a Massa de Dados (5.000 Vendas + Estoque em Tempo Real)

No terminal, rode apenas:

```bash
cd /home/alisson_qinetwork_com_br/Documents/env-config/data-ai-presales/automation
make seed-analytics-bq PROJECT_ID=gemini-demo-qi
```

Isso criará no dataset **`gemini-demo-qi.retail_omnicanal`** (100% documentado em português para o modelo entender cada coluna):

| Tabela / View no BigQuery | Volume | Para que serve na Demo |
| :--- | :--- | :--- |
| `vendas_historico_analytics` | **5.000 pedidos** (12 meses) | Gráficos de tendência mensal, análise de canais, impacto da ruptura de estoque, NPS e **Receita Salva pela IA (Ship-from-Store)**. |
| `estoque_lojas_tempo_real` | **8 posições críticas SKU/Loja** | Mostrar quais CDs estão zerados (`CRITICO_RUPTURA`) e quais lojas físicas têm saldo excedente para salvar vendas. |
| `orders_and_inventory_360` | **Pedidos ao vivo (`PED-9082`, etc.)** | Usada pelo Agente ADK Python/Go na demo transacional. |
| `vw_kpis_executivos_varejo` | **View Consolidada de ROI** | Respostas imediatas de C-Level sobre margem e retorno financeiro. |

> **💡 Dica Bônus (Dataset Público do Google):** Se o cliente quiser ver uma consulta em milhões de linhas além do nosso dataset, o BigQuery já inclui gratuitamente o dataset público `bigquery-public-data.thelook_ecommerce` (`orders`, `order_items`, `products`, `users`). Porém, use **`gemini-demo-qi.retail_omnicanal.vendas_historico_analytics`** como principal porque todas as colunas estão em Português e conectadas à narrativa dos nossos Agentes!

---

## 🖥️ Passo 2: Como Demonstrar em Cada Interface (UI)

### Cenário A: BigQuery Conversational Analytics (No Console do BigQuery)
1. Acesse: `https://console.cloud.google.com/bigquery?project=gemini-demo-qi`
2. No menu lateral esquerdo do BigQuery Studio, clique em **"Agents" / "Conversational Analytics"** (ou clique nos três pontinhos ao lado da tabela `vendas_historico_analytics` $\rightarrow$ **"Query with Conversational Analytics / Ask Gemini"**).
3. Se quiser criar um **Data Agent reutilizável**:
   * Selecione as tabelas `vendas_historico_analytics` e `estoque_lojas_tempo_real`.
   * Em *Instructions / Context*, cole:
     `"Você é o Analista Executivo de Varejo Omnicanal da QI Network. Sempre apresente valores financeiros em Reais (R$) e destaque quanto de receita foi salvo pela modalidade Ship-from-Store quando houve ruptura no CD."`

### Cenário B: Conector BigQuery no Seu App Gemini Enterprise (`alisson-demo_1792679266221`)
1. Acesse o painel do seu app:
   `https://console.cloud.google.com/gemini-enterprise/locations/global/engines/alisson-demo_1792679266221/overview/dashboard?project=gemini-demo-qi`
2. Vá em **Data Stores** $\rightarrow$ **Add Data Store** $\rightarrow$ escolha **BigQuery**.
3. Selecione a tabela **`gemini-demo-qi.retail_omnicanal.vendas_historico_analytics`** (e `estoque_lojas_tempo_real`).
4. Agora, dentro do Web App do **Gemini Enterprise**, o usuário de negócio pode fazer perguntas que **cruzam o PDF do Manual de Operações (Cloud Storage) com os números reais do BigQuery**!

---

## 🎯 Passo 3: 7 Prompts "Matadores" para Copiar e Colar na Demo

Use esta sequência de perguntas (do nível executivo até a causa-raiz operacional) durante a reunião:

### 1. Pergunta de Receita e Performance por Categoria (Gera Gráfico de Barras)
> 💬 `"Qual é a receita líquida total e a margem de lucro por categoria de produto nos últimos 12 meses? Ordene da maior para a menor."`

### 2. Pergunta de ROI da IA — O "Momento Uau" para o CFO/CEO!
> 💬 `"Quantos pedidos sofreram ruptura no CD Central e quanto de receita líquida em Reais nós conseguimos salvar graças ao redirecionamento Ship-from-Store dos agentes?"`
*(Mostra na hora que, de ~500 pedidos que seriam cancelados por falta de estoque no CD, ~80% foram salvos pelas lojas físicas, recuperando mais de R$ 2,5 milhões em receita!)*

### 3. Pergunta de Comparação de Canais e Satisfação (NPS + Tempo de Entrega)
> 💬 `"Compare o tempo médio de entrega em horas e a nota média de NPS entre os pedidos salvos via Ship-from-Store (2h), os entregues no prazo normal e os cancelados por ruptura."`

### 4. Pergunta de Evolução Temporal (Gera Gráfico de Linha Mensal)
> 💬 `"Mostre um gráfico da evolução mensal (mes_ano) da receita bruta separada por canal de venda (App Mobile, E-commerce Web, Loja Física e WhatsApp AI Concierge)."`

### 5. Pergunta Operacional de Estoque em Tempo Real (`estoque_lojas_tempo_real`)
> 💬 `"Quais produtos estão com status CRITICO_RUPTURA ou ALERTA_BAIXO_ESTOQUE nos nossos Centros de Distribuição hoje, e quais lojas físicas têm estoque saudável desses mesmos produtos para cobrir a demanda?"`

### 6. Pergunta Híbrida no Gemini Enterprise (Cruza PDF + BigQuery)
> 💬 `"De acordo com o nosso Manual de Operações de Varejo, qual é a regra para ruptura de clientes Diamante VIP, e qual foi o total de cashback concedido para clientes Diamante VIP na tabela de vendas?"`
*(Essa pergunta vende o **Gemini Enterprise** na hora: nenhuma ferramenta tradicional de BI consegue ler a regra de um arquivo HTML/PDF no Cloud Storage e, na mesma resposta, somar uma coluna financeira no BigQuery!)*
