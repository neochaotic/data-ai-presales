#!/usr/bin/env bash
# ============================================================================
# Script gcloud + bq + storage + Discovery Engine API para Provisionar a Demo
# de Varejo Omnicanal no Projeto: gemini-demo-qi
# App Gemini Enterprise: alisson-demo_1792679266221 (location: global)
# ============================================================================
set -euo pipefail

PROJECT_ID="${1:-gemini-demo-qi}"
REGION="${2:-us-central1}"
GE_LOCATION="global"
GE_ENGINE_ID="${3:-alisson-demo_1792679266221}"
BQ_DATASET="retail_omnicanal"
BQ_TABLE="orders_and_inventory_360"
BUCKET_NAME="${PROJECT_ID}-retail-kb"

echo "======================================================================"
echo " 🛒 Provisionando Demo Varejo no GCP (${PROJECT_ID})"
echo " 🏢 Gemini Enterprise App: ${GE_ENGINE_ID} (${GE_LOCATION})"
echo "======================================================================"

# 1. Define projeto ativo e habilita APIs
gcloud config set project "${PROJECT_ID}"

echo "📦 [1/5] Habilitando APIs do Google Cloud..."
gcloud services enable \
  aiplatform.googleapis.com \
  discoveryengine.googleapis.com \
  bigquery.googleapis.com \
  storage.googleapis.com \
  cloudtrace.googleapis.com \
  logging.googleapis.com \
  run.googleapis.com \
  --project="${PROJECT_ID}"

# 2. Cria Bucket no Cloud Storage e sobe o Manual de Operações de Varejo (HTML/TXT para indexação no Gemini Enterprise)
echo "🪣 [2/5] Criando Bucket gs://${BUCKET_NAME} para políticas de Varejo..."
if ! gcloud storage buckets describe "gs://${BUCKET_NAME}" --project="${PROJECT_ID}" >/dev/null 2>&1; then
  gcloud storage buckets create "gs://${BUCKET_NAME}" \
    --project="${PROJECT_ID}" \
    --location="${REGION}" \
    --uniform-bucket-level-access
else
  echo "   -> Bucket gs://${BUCKET_NAME} já existe."
fi

TMP_POLICY_FILE="/tmp/manual-operacoes-omnicanal-2026.html"
cat << 'EOF' > "${TMP_POLICY_FILE}"
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <title>Manual Oficial de Operações e Políticas de Varejo Omnicanal (2026) - QI Network</title>
</head>
<body>
  <h1>Manual Oficial de Operações e Políticas de Varejo Omnicanal (2026)</h1>
  <p><strong>Código de Governança:</strong> POL-RET-2026-V4 | <strong>Projeto:</strong> gemini-demo-qi</p>

  <h2>1. Política de Ruptura de Estoque e Atraso Logístico (Save-the-Sale)</h2>
  <ul>
    <li><strong>Regra Geral:</strong> Quando um pedido de cliente sofrer ruptura no Centro de Distribuição (CD) ou atraso superior a 24 horas, o Agente Orquestrador deve buscar estoque disponível nas lojas físicas num raio de até 15 km do endereço de entrega.</li>
    <li><strong>Clientes Diamante e Ouro (VIP):</strong> Acionar automaticamente a modalidade <strong>Ship-from-Store Express (Entrega em 2 horas)</strong> a partir da loja física mais próxima com estoque e conceder <strong>10% de Cashback / Voucher imediato</strong> sobre o valor do pedido (código <code>VIP10-&lt;PEDIDO&gt;</code>).</li>
  </ul>

  <h2>2. Política de Trocas e Devoluções (Loja Física e E-commerce)</h2>
  <ul>
    <li><strong>Prazo Legal (CDC):</strong> 7 dias corridos após o recebimento para compras online.</li>
    <li><strong>Benefício Fidelidade Ouro e Diamante:</strong> Prazo estendido para <strong>30 dias corridos</strong>, inclusive para produtos com <strong>caixa aberta</strong> (ex: Smart TVs, Geladeiras e Smartphones), desde que não apresentem dano físico ou mau uso.</li>
    <li><strong>Avaria no Transporte:</strong> Em caso de avaria reportada na entrega (ex: amassado em eletrodoméstico), acionar coleta reversa simultânea à entrega de novo item via loja física ou CD regional mais próximo.</li>
  </ul>

  <h2>3. Matriz de Alçada Financeira (Governança do Agente Transacional em Go)</h2>
  <ul>
    <li><strong>Aprovação Automática (Sub-milissegundo via Agente Go ADK):</strong> Pedidos com valor total até <strong>R$ 15.000,00</strong> e Score de Risco inferior a <code>0.45</code> são aprovados automaticamente sem intervenção humana.</li>
    <li><strong>Escalonamento Obrigatório (Human-in-the-Loop no Gemini Enterprise):</strong> Pedidos corporativos (B2B) ou de alto valor acima de <strong>R$ 15.000,00</strong> (como lotes de ar-condicionado ou compras atacado) devem ser bloqueados para aprovação automática e encaminhados à fila do Diretor de Operações no <strong>Gemini Enterprise</strong>.</li>
  </ul>
</body>
</html>
EOF

gcloud storage cp "${TMP_POLICY_FILE}" "gs://${BUCKET_NAME}/manual-operacoes-omnicanal-2026.html" --project="${PROJECT_ID}"
echo "   -> Manual enviado para gs://${BUCKET_NAME}/manual-operacoes-omnicanal-2026.html"

# 3. Cria Dataset e Tabela no BigQuery
echo "📊 [3/5] Criando Dataset e Tabela no BigQuery (${PROJECT_ID}:${BQ_DATASET}.${BQ_TABLE})..."
if ! bq --project_id="${PROJECT_ID}" show "${BQ_DATASET}" >/dev/null 2>&1; then
  bq --location="${REGION}" --project_id="${PROJECT_ID}" mk --dataset \
    --description="Dataset de Varejo Omnicanal para Demo Vertex AI ADK e Gemini Enterprise (${GE_ENGINE_ID})" \
    "${PROJECT_ID}:${BQ_DATASET}"
fi

bq --project_id="${PROJECT_ID}" query --use_legacy_sql=false <<EOF
CREATE OR REPLACE TABLE \`${PROJECT_ID}.${BQ_DATASET}.${BQ_TABLE}\` (
  order_id STRING,
  customer_id STRING,
  customer_name STRING,
  loyalty_tier STRING,
  ltv_anual_brl FLOAT64,
  product_name STRING,
  order_value_brl FLOAT64,
  current_status STRING,
  nearest_store_with_stock STRING,
  payment_score FLOAT64,
  updated_at TIMESTAMP
);

INSERT INTO \`${PROJECT_ID}.${BQ_DATASET}.${BQ_TABLE}\`
(order_id, customer_id, customer_name, loyalty_tier, ltv_anual_brl, product_name, order_value_brl, current_status, nearest_store_with_stock, payment_score, updated_at)
VALUES
  ('PED-9082', 'CLI-MARINA-9082', 'Marina Silva', 'Cliente Diamante (VIP)', 48500.00, 'Smart TV 65" OLED 4K Ultra Vision', 6490.00, 'RUPTURA_NO_CD_CENTRAL (Atraso de 36h)', 'Loja Fisica #12 - Shopping Ibirapuera (3.2 km, 4 unid. em estoque)', 99.0, CURRENT_TIMESTAMP()),
  ('PED-4010', 'CLI-CARLOS-4010', 'Carlos Eduardo Mendes', 'Cliente Ouro', 12400.00, 'Geladeira Smart French Door Inox 540L', 8900.00, 'AVARIA_NO_TRANSPORTE (Solicitacao de Troca Expressa)', 'Loja Fisica #05 - BarraShopping (5.1 km, 2 unid. em estoque)', 95.0, CURRENT_TIMESTAMP()),
  ('PED-7721', 'CLI-B2B-7721', 'Rede Hoteleira Atlantico (B2B)', 'Corporate B2B', 390000.00, 'Lote 15x Ar-Condicionado Split Inverter 18.000 BTUs', 54000.00, 'ATRASO_TRANSPORTADORA (Solicitacao de Estorno Total)', 'CD Regional Sul (Requer frota dedicada e aprovacao de Diretoria)', 82.0, CURRENT_TIMESTAMP());
EOF

# 4. Verifica o Engine do Gemini Enterprise via API REST (Discovery Engine)
echo "🏢 [4/5] Verificando Engine do Gemini Enterprise (${GE_ENGINE_ID})..."
ACCESS_TOKEN="$(gcloud auth print-access-token 2>/dev/null || true)"
if [ -n "${ACCESS_TOKEN}" ]; then
  curl -s -X GET \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "X-Goog-User-Project: ${PROJECT_ID}" \
    "https://discoveryengine.googleapis.com/v1alpha/projects/${PROJECT_ID}/locations/${GE_LOCATION}/collections/default_collection/engines/${GE_ENGINE_ID}" \
    | head -c 400 || true
  echo ""
fi

echo "✅ [5/5] Ambiente de Varejo provisionado com sucesso!"
echo ""
echo "======================================================================"
echo " 🎯 PRÓXIMOS CLIQUES NA UI DO SEU APP GEMINI ENTERPRISE:"
echo " 🔗 https://console.cloud.google.com/gemini-enterprise/locations/${GE_LOCATION}/engines/${GE_ENGINE_ID}/overview/dashboard?project=${PROJECT_ID}"
echo "======================================================================"
echo "1. No menu lateral do app '${GE_ENGINE_ID}', clique em 'Data Stores' (Fontes de Dados):"
echo "   - Adicione Cloud Storage -> selecione: gs://${BUCKET_NAME}/manual-operacoes-omnicanal-2026.html"
echo "   - Adicione BigQuery      -> selecione: ${PROJECT_ID}.${BQ_DATASET}.${BQ_TABLE}"
echo "2. Após rodar 'make deploy-agent-engine', vá em 'Agents' dentro do '${GE_ENGINE_ID}'"
echo "   e conecte o agente Vertex AI Agent Engine publicado!"
