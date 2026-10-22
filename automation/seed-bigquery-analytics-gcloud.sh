#!/usr/bin/env bash
# ============================================================================
# Gerador de Massa de Dados Realista para BigQuery Conversational Analytics
# e Conector Estruturado do Gemini Enterprise (alisson-demo_1792679266221)
# Projeto Alvo: gemini-demo-qi | Dataset: retail_omnicanal
# ============================================================================
set -euo pipefail

PROJECT_ID="${1:-gemini-demo-qi}"
REGION="${2:-us-central1}"
BQ_DATASET="retail_omnicanal"

echo "======================================================================"
echo " 📊 Populando Dados para Conversational Analytics & Gemini Enterprise"
echo "    Projeto: ${PROJECT_ID} | Dataset: ${BQ_DATASET}"
echo "======================================================================"

gcloud config set project "${PROJECT_ID}"

# 1. Garante que o dataset exista
if ! bq --project_id="${PROJECT_ID}" show "${BQ_DATASET}" >/dev/null 2>&1; then
  bq --location="${REGION}" --project_id="${PROJECT_ID}" mk --dataset \
    --description="Dataset de Varejo Omnicanal com metadados semanticos para Conversational Analytics e Gemini Enterprise" \
    "${PROJECT_ID}:${BQ_DATASET}"
fi

# 2. Cria Tabela 1: vendas_historico_analytics (5.000 transações omnicanal com descrições semânticas)
echo "🚀 [1/3] Gerando 5.000 vendas históricas em '${BQ_DATASET}.vendas_historico_analytics'..."
bq --project_id="${PROJECT_ID}" query --use_legacy_sql=false <<EOF
CREATE OR REPLACE TABLE \`${PROJECT_ID}.${BQ_DATASET}.vendas_historico_analytics\`
(
  id_transacao STRING OPTIONS(description="Identificador único da venda ou pedido no varejo omnicanal"),
  data_venda DATE OPTIONS(description="Data em que a venda foi realizada (últimos 12 meses)"),
  mes_ano STRING OPTIONS(description="Mês e ano da venda no formato YYYY-MM para análises de tendência mensal"),
  canal_venda STRING OPTIONS(description="Canal de origem da venda: App Mobile, E-commerce Web, Loja Física ou WhatsApp AI Concierge"),
  loja_ou_cd STRING OPTIONS(description="Nome da loja física ou Centro de Distribuição (CD) responsável pelo pedido"),
  estado_uf STRING OPTIONS(description="Sigla do estado brasileiro (SP, RJ, MG, PR, RS, PE, BA, DF)"),
  categoria_produto STRING OPTIONS(description="Categoria de negócio: Smart TVs & Áudio, Linha Branca & Geladeiras, Smartphones, Climatização ou Informática"),
  nome_produto STRING OPTIONS(description="Nome comercial do SKU vendido"),
  tier_fidelidade STRING OPTIONS(description="Segmento do cliente: Diamante VIP, Ouro, Prata ou Corporate B2B"),
  quantidade INT64 OPTIONS(description="Quantidade de itens comprados no pedido"),
  receita_bruta_brl FLOAT64 OPTIONS(description="Valor total bruto da venda em Reais (R$)"),
  desconto_ou_cashback_brl FLOAT64 OPTIONS(description="Valor de desconto promocional ou cashback concedido em Reais (R$)"),
  receita_liquida_brl FLOAT64 OPTIONS(description="Receita líquida após descontos e cashback em Reais (R$)"),
  margem_lucro_brl FLOAT64 OPTIONS(description="Margem de contribuição líquida da venda em Reais (R$)"),
  teve_ruptura_cd BOOL OPTIONS(description="TRUE se faltou estoque no Centro de Distribuição principal após a venda"),
  salvo_por_ship_from_store BOOL OPTIONS(description="TRUE se o Agente ADK salvou a venda redirecionando para o estoque de uma loja física próxima"),
  status_pedido STRING OPTIONS(description="Status final do pedido: ENTREGUE_NO_PRAZO, SALVO_SHIP_FROM_STORE_2H, ENTREGUE_COM_ATRASO ou CANCELADO_RUPTURA"),
  tempo_entrega_horas FLOAT64 OPTIONS(description="Tempo total em horas entre a aprovação do pedido e a entrega ao cliente"),
  nps_nota INT64 OPTIONS(description="Nota de satisfação do cliente (0 a 10) coletada pós-entrega")
)
OPTIONS(
  description="Tabela histórica de vendas omnicanal da QI Network Varejo para análises no Conversational Analytics e Gemini Enterprise. Contém métricas de receita, margem, ruptura de estoque, Ship-from-Store via IA e NPS."
)
AS
WITH raw_gen AS (
  SELECT
    num AS seq,
     ABS(FARM_FINGERPRINT(CAST(num AS STRING))) AS h1,
    ABS(FARM_FINGERPRINT(CONCAT('salt2_', CAST(num AS STRING)))) AS h2,
    ABS(FARM_FINGERPRINT(CONCAT('salt3_', CAST(num AS STRING)))) AS h3
  FROM UNNEST(GENERATE_ARRAY(1, 5000)) AS num
),
mapped AS (
  SELECT
     FORMAT('PED-%06d', seq + 10000) AS id_transacao,
    DATE_SUB(CURRENT_DATE(), INTERVAL MOD(h1, 365) DAY) AS data_venda,
    CASE MOD(h1, 4)
      WHEN 0 THEN 'App Mobile'
      WHEN 1 THEN 'E-commerce Web'
      WHEN 2 THEN 'Loja Física'
      ELSE 'WhatsApp AI Concierge'
    END AS canal_venda,
    CASE MOD(h2, 6)
      WHEN 0 THEN 'Loja #12 - Shopping Ibirapuera (SP)'
      WHEN 1 THEN 'Loja #08 - Shopping Morumbi (SP)'
      WHEN 2 THEN 'Loja #05 - BarraShopping (RJ)'
      WHEN 3 THEN 'Loja #19 - Pátio Batel (PR)'
      WHEN 4 THEN 'CD Central Cajamar (SP)'
      ELSE 'CD Regional Sul (PR)'
    END AS loja_ou_cd,
    CASE MOD(h2, 6)
      WHEN 0 THEN 'SP'
      WHEN 1 THEN 'SP'
      WHEN 2 THEN 'RJ'
      WHEN 3 THEN 'PR'
      WHEN 4 THEN 'SP'
      ELSE 'PR'
    END AS estado_uf,
    CASE MOD(h3, 5)
      WHEN 0 THEN 'Smart TVs & Áudio'
      WHEN 1 THEN 'Linha Branca & Geladeiras'
      WHEN 2 THEN 'Smartphones'
      WHEN 3 THEN 'Climatização'
      ELSE 'Informática & Gamer'
    END AS categoria_produto,
    CASE MOD(h3, 5)
      WHEN 0 THEN 'Smart TV 65" OLED 4K Ultra Vision'
      WHEN 1 THEN 'Geladeira Smart French Door Inox 540L'
      WHEN 2 THEN 'Smartphone Flagship Pro 512GB AI'
      WHEN 3 THEN 'Ar-Condicionado Split Inverter 18.000 BTUs'
      ELSE 'Notebook Ultra Pro 32GB RTX'
    END AS nome_produto,
    CASE MOD(h1, 5)
      WHEN 0 THEN 'Diamante VIP'
      WHEN 1 THEN 'Ouro'
      WHEN 2 THEN 'Prata'
      WHEN 3 THEN 'Prata'
      ELSE 'Corporate B2B'
    END AS tier_fidelidade,
    1 + MOD(h2, 3) AS quantidade,
    CASE MOD(h3, 5)
      WHEN 0 THEN 6490.00
      WHEN 1 THEN 8900.00
      WHEN 2 THEN 5200.00
      WHEN 3 THEN 3600.00
      ELSE 7800.00
    END AS preco_unitario,
    MOD(h1, 10) = 0 AS teve_ruptura_cd,
    MOD(h2, 10) IN (0, 1, 2, 3, 4, 5, 6, 7) AS elegivel_ship_from_store,
    h3
  FROM raw_gen
)
SELECT
  id_transacao,
  data_venda,
  FORMAT_DATE('%Y-%m', data_venda) AS mes_ano,
  canal_venda,
  loja_ou_cd,
  estado_uf,
  categoria_produto,
  nome_produto,
  tier_fidelidade,
  quantidade,
  ROUND(quantidade * preco_unitario, 2) AS receita_bruta_brl,
  ROUND(
    CASE
      WHEN teve_ruptura_cd AND elegivel_ship_from_store THEN (quantidade * preco_unitario) * 0.10
      ELSE (quantidade * preco_unitario) * 0.03
    END, 2
  ) AS desconto_ou_cashback_brl,
  ROUND(
    (quantidade * preco_unitario) - (
      CASE
        WHEN teve_ruptura_cd AND elegivel_ship_from_store THEN (quantidade * preco_unitario) * 0.10
        ELSE (quantidade * preco_unitario) * 0.03
      END
    ), 2
  ) AS receita_liquida_brl,
  ROUND((quantidade * preco_unitario) * 0.28, 2) AS margem_lucro_brl,
  teve_ruptura_cd,
  (teve_ruptura_cd AND elegivel_ship_from_store) AS salvo_por_ship_from_store,
  CASE
    WHEN NOT teve_ruptura_cd THEN 'ENTREGUE_NO_PRAZO'
    WHEN teve_ruptura_cd AND elegivel_ship_from_store THEN 'SALVO_SHIP_FROM_STORE_2H'
    ELSE 'CANCELADO_RUPTURA'
  END AS status_pedido,
  CASE
    WHEN teve_ruptura_cd AND elegivel_ship_from_store THEN 2.1
    WHEN NOT teve_ruptura_cd THEN 18.5 + MOD(h3, 24)
    ELSE 72.0
  END AS tempo_entrega_horas,
  CASE
    WHEN teve_ruptura_cd AND elegivel_ship_from_store THEN 9 + MOD(h3, 2)
    WHEN NOT teve_ruptura_cd THEN 8 + MOD(h3, 3)
    ELSE 3 + MOD(h3, 4)
  END AS nps_nota
FROM mapped;
EOF

# 3. Cria Tabela 2: estoque_lojas_tempo_real (Visão Omnicanal de Estoque e Risco de Ruptura)
echo "📦 [2/3] Criando tabela '${BQ_DATASET}.estoque_lojas_tempo_real'..."
bq --project_id="${PROJECT_ID}" query --use_legacy_sql=false <<EOF
CREATE OR REPLACE TABLE \`${PROJECT_ID}.${BQ_DATASET}.estoque_lojas_tempo_real\`
(
  sku_id STRING OPTIONS(description="Código identificador do produto (SKU)"),
  nome_produto STRING OPTIONS(description="Nome do produto"),
  categoria_produto STRING OPTIONS(description="Categoria do produto"),
  unidade_logistica STRING OPTIONS(description="Nome da Loja Física ou Centro de Distribuição"),
  tipo_unidade STRING OPTIONS(description="LOJA_FISICA ou CENTRO_DISTRIBUICAO"),
  estado_uf STRING OPTIONS(description="UF da unidade (SP, RJ, PR)"),
  estoque_disponivel INT64 OPTIONS(description="Quantidade atual em estoque livre para venda ou Ship-from-Store"),
  estoque_minimo_seguranca INT64 OPTIONS(description="Ponto de ressuprimento mínimo"),
  demanda_diaria_prevista FLOAT64 OPTIONS(description="Previsão de vendas diárias calculada por IA"),
  cobertura_dias FLOAT64 OPTIONS(description="Quantos dias o estoque atual dura com base na demanda prevista"),
  risco_ruptura STRING OPTIONS(description="Classificação de risco: CRITICO_RUPTURA, ALERTA_BAIXO_ESTOQUE ou SAUDAVEL"),
  valor_estoque_brl FLOAT64 OPTIONS(description="Valor financeiro total do estoque parado na unidade em Reais (R$)")
)
OPTIONS(
  description="Tabela de posição de estoque em tempo real por loja física e CD para análises de ruptura e remanejamento Ship-from-Store."
);

INSERT INTO \`${PROJECT_ID}.${BQ_DATASET}.estoque_lojas_tempo_real\`
VALUES
  ('SKU-TV-65OLED', 'Smart TV 65" OLED 4K Ultra Vision', 'Smart TVs & Áudio', 'CD Central Cajamar (SP)', 'CENTRO_DISTRIBUICAO', 'SP', 0, 25, 8.5, 0.0, 'CRITICO_RUPTURA', 0.00),
  ('SKU-TV-65OLED', 'Smart TV 65" OLED 4K Ultra Vision', 'Smart TVs & Áudio', 'Loja #12 - Shopping Ibirapuera (SP)', 'LOJA_FISICA', 'SP', 14, 4, 1.5, 9.3, 'SAUDAVEL', 90860.00),
  ('SKU-TV-65OLED', 'Smart TV 65" OLED 4K Ultra Vision', 'Smart TVs & Áudio', 'Loja #08 - Shopping Morumbi (SP)', 'LOJA_FISICA', 'SP', 9, 4, 1.2, 7.5, 'SAUDAVEL', 58410.00),
  ('SKU-GEL-540L', 'Geladeira Smart French Door Inox 540L', 'Linha Branca & Geladeiras', 'CD Central Cajamar (SP)', 'CENTRO_DISTRIBUICAO', 'SP', 4, 15, 4.0, 1.0, 'ALERTA_BAIXO_ESTOQUE', 35600.00),
  ('SKU-GEL-540L', 'Geladeira Smart French Door Inox 540L', 'Linha Branca & Geladeiras', 'Loja #05 - BarraShopping (RJ)', 'LOJA_FISICA', 'RJ', 6, 2, 0.8, 7.5, 'SAUDAVEL', 53400.00),
  ('SKU-AR-18K', 'Ar-Condicionado Split Inverter 18.000 BTUs', 'Climatização', 'CD Regional Sul (PR)', 'CENTRO_DISTRIBUICAO', 'PR', 42, 20, 5.2, 8.1, 'SAUDAVEL', 151200.00),
  ('SKU-PHONE-512', 'Smartphone Flagship Pro 512GB AI', 'Smartphones', 'Loja #19 - Pátio Batel (PR)', 'LOJA_FISICA', 'PR', 2, 8, 3.0, 0.6, 'CRITICO_RUPTURA', 10400.00),
  ('SKU-NOTE-RTX', 'Notebook Ultra Pro 32GB RTX', 'Informática & Gamer', 'Loja #12 - Shopping Ibirapuera (SP)', 'LOJA_FISICA', 'SP', 11, 5, 1.1, 10.0, 'SAUDAVEL', 85800.00);
EOF

# 4. Cria View de KPIs Executivos para Respostas Instantâneas no Gemini Enterprise
echo "📈 [3/3] Criando View Executiva '${BQ_DATASET}.vw_kpis_executivos_varejo'..."
bq --project_id="${PROJECT_ID}" query --use_legacy_sql=false <<EOF
CREATE OR REPLACE VIEW \`${PROJECT_ID}.${BQ_DATASET}.vw_kpis_executivos_varejo\`
OPTIONS(
  description="Visão consolidada de KPIs por categoria e canal mostrando quanto de receita foi salvo pelo agente de Ship-from-Store."
) AS
SELECT
  categoria_produto,
  canal_venda,
  COUNT(id_transacao) AS total_pedidos,
  ROUND(SUM(receita_bruta_brl), 2) AS receita_bruta_total_brl,
  ROUND(SUM(receita_liquida_brl), 2) AS receita_liquida_total_brl,
  COUNTIF(teve_ruptura_cd) AS total_pedidos_com_ruptura_cd,
  COUNTIF(salvo_por_ship_from_store) AS pedidos_salvos_pela_ia,
  ROUND(SUM(IF(salvo_por_ship_from_store, receita_liquida_brl, 0)), 2) AS receita_salva_pela_ia_brl,
  ROUND(AVG(tempo_entrega_horas), 1) AS tempo_medio_entrega_horas,
  ROUND(AVG(nps_nota), 2) AS nps_medio
FROM \`${PROJECT_ID}.${BQ_DATASET}.vendas_historico_analytics\`
GROUP BY categoria_produto, canal_venda;
EOF

echo "======================================================================"
echo "✅ Massa de Dados para Conversational Analytics criada com sucesso!"
echo "======================================================================"
echo "Tabelas disponíveis em ${PROJECT_ID}.${BQ_DATASET}:"
echo "  1. vendas_historico_analytics  (5.000 linhas com histórico de 12 meses)"
echo "  2. estoque_lojas_tempo_real    (Matriz de estoque CD vs Lojas Físicas)"
echo "  3. orders_and_inventory_360    (Pedidos específicos do roteiro ADK)"
echo "  4. vw_kpis_executivos_varejo   (View executiva de ROI / Receita Salva)"
echo ""
echo "🔗 Abra o BigQuery Studio (Conversational Analytics) em:"
echo "   https://console.cloud.google.com/bigquery?project=${PROJECT_ID}"
