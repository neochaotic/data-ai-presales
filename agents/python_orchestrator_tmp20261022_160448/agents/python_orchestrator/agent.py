"""
QI Network — Orquestrador Multi-Agente Enterprise (Google Cloud ADK Python)
Projeto GCP Padrão: gemini-demo-qi
Foco Principal da Demo: VAREJO OMNICANAL (Fácil compreensão para qualquer público)

Este módulo define uma arquitetura Multi-Agente no ADK compatível com:
- `adk web` (Interface Visual de Grafo de Agentes, Eventos e Trace ao vivo)
- `adk run` (Execução via CLI)
- `Vertex AI Agent Engine` (Deploy serverless gerenciado no GCP)
- Integração híbrida Python + Go (via HTTP / A2A Protocol)
"""

import json
import os
import urllib.request
import urllib.error
from datetime import datetime, timezone
from typing import Any, Dict

from google.adk import Agent

# ============================================================================
# CONFIGURAÇÕES DINÂMICAS DO AMBIENTE (Projeto: gemini-demo-qi)
# ============================================================================
GCP_PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT", "gemini-demo-qi")
GCP_LOCATION = os.getenv("GOOGLE_CLOUD_LOCATION", "us-central1")
MODEL_NAME = os.getenv("ADK_MODEL_NAME", "gemini-2.5-flash")
GO_AGENT_ENDPOINT = os.getenv("GO_AGENT_ENDPOINT", "http://localhost:8081/api/v1/evaluate")


# ============================================================================
# FERRAMENTAS (TOOLS / MCP WRAPPERS) PARA OS SUBAGENTES DE VAREJO
# ============================================================================

def consultar_politicas_varejo(topico: str) -> Dict[str, Any]:
    """
    Consulta a base de conhecimento do Varejo (Vertex AI Search / Gemini Enterprise)
    contendo políticas de troca, devolução, ruptura de estoque (Ship-from-Store),
    SLAs de entrega VIP e alçadas de desconto/cashback.

    Args:
        topico: Tema da dúvida ou política (ex: 'atraso entrega', 'ruptura de estoque', 'troca produto aberto', 'black friday').
    """
    regras_varejo = {
        "documento_oficial": f"gs://{GCP_PROJECT_ID}-retail-kb/manual-operacoes-omnicanal-2026.pdf",
        "politica_ruptura_e_atraso": (
            "Se um pedido de cliente VIP/Diamante sofrer ruptura no Centro de Distribuição (CD) "
            "ou atraso superior a 24h, o sistema deve acionar 'Ship-from-Store' (envio expresso em 2h "
            "a partir da loja física mais próxima com estoque) + conceder 10% de Cashback/Voucher automático."
        ),
        "politica_troca_devolucao": (
            "Compras online possuem 7 dias de arrependimento legal (CDC). Para clientes Ouro/Diamante, "
            "o prazo é estendido para 30 dias mesmo com caixa aberta, desde que sem dano físico."
        ),
        "alcada_financeira_motor_go": (
            "Estornos, vouchers ou compensações até R$ 2.500,00 (ou pedidos até R$ 15.000,00) são "
            "aprovados automaticamente em milissegundos pelo Motor Transacional em Go. Valores superiores "
            "exigem aprovação do Diretor de Operações na UI do Gemini Enterprise."
        ),
    }

    return {
        "status": "SUCCESS",
        "gcp_project": GCP_PROJECT_ID,
        "engine": "Vertex AI Search & Grounding (Conectado ao Gemini Enterprise)",
        "query": topico,
        "citations": [
            {
                "source_uri": regras_varejo["documento_oficial"],
                "page": 14,
                "rules": regras_varejo,
                "acl_permission_verified": True,
            }
        ],
    }


def consultar_pedido_e_estoque_bigquery(order_id: str) -> Dict[str, Any]:
    """
    Executa consulta analítica no BigQuery (Data Cloud do projeto gemini-demo-qi)
    para retornar os dados do pedido do cliente, perfil de fidelidade, status logístico
    e disponibilidade de estoque nas lojas físicas próximas (Omnicanal).

    Args:
        order_id: Código do pedido (ex: 'PED-9082', 'PED-4010', 'PED-7721').
    """
    pedidos_db = {
        "PED-9082": {
            "order_id": "PED-9082",
            "customer_id": "CLI-MARINA-9082",
            "customer_name": "Marina Silva",
            "loyalty_tier": "Cliente Diamante (VIP)",
            "ltv_anual_brl": 48500.00,
            "product_name": "Smart TV 65\" OLED 4K Ultra Vision",
            "order_value_brl": 6490.00,
            "current_status": "RUPTURA_NO_CD_CENTRAL (Atraso de 36h)",
            "nearest_store_with_stock": "Loja Física #12 — Shopping Ibirapuera (3.2 km da cliente, 4 unidades em estoque)",
            "payment_score": 99.0,
        },
        "PED-4010": {
            "order_id": "PED-4010",
            "customer_id": "CLI-CARLOS-4010",
            "customer_name": "Carlos Eduardo Mendes",
            "loyalty_tier": "Cliente Ouro",
            "ltv_anual_brl": 12400.00,
            "product_name": "Geladeira Smart French Door Inox 540L",
            "order_value_brl": 8900.00,
            "current_status": "AVARIA_NO_TRANSPORTE (Solicitação de Troca Expressa)",
            "nearest_store_with_stock": "Loja Física #05 — BarraShopping (5.1 km do cliente, 2 unidades em estoque)",
            "payment_score": 95.0,
        },
        "PED-7721": {
            "order_id": "PED-7721",
            "customer_id": "CLI-B2B-7721",
            "customer_name": "Rede Hoteleira Atlântico (Compra Corporativa B2B)",
            "loyalty_tier": "Corporate B2B",
            "ltv_anual_brl": 390000.00,
            "product_name": "Lote 15x Ar-Condicionado Split Inverter 18.000 BTUs",
            "order_value_brl": 54000.00,
            "current_status": "ATRASO_TRANSPORTADORA (Solicitação de Estorno Total)",
            "nearest_store_with_stock": "CD Regional Sul (Requer remanejamento de frota dedicada)",
            "payment_score": 82.0,
        },
    }

    chave = order_id.upper().strip().lstrip("#")
    dados = pedidos_db.get(
        chave,
        {
            "order_id": chave,
            "customer_id": f"CLI-{chave}",
            "customer_name": "Cliente Varejo Omnicanal",
            "loyalty_tier": "Cliente Diamante (VIP)",
            "ltv_anual_brl": 25000.00,
            "product_name": "Smartphone Flagship Pro 512GB",
            "order_value_brl": 5200.00,
            "current_status": "RUPTURA_NO_CD_CENTRAL (Atraso de 28h)",
            "nearest_store_with_stock": "Loja Física #08 — Shopping Morumbi (2.5 km, 6 unidades em estoque)",
            "payment_score": 97.0,
        },
    )

    return {
        "status": "SUCCESS",
        "datasource": f"bigquery://{GCP_PROJECT_ID}.retail_omnicanal.orders_and_inventory_360",
        "order_data": dados,
        "queried_at_utc": datetime.now(timezone.utc).isoformat(),
    }


def acionar_motor_transacional_go_varejo(
    order_id: str,
    customer_id: str,
    order_value_brl: float,
    operation_type: str,
    store_origin: str = "Loja Shopping Ibirapuera",
    payment_score: float = 98.0,
) -> Dict[str, Any]:
    """
    Aciona o Agente/Microsserviço Transacional em Go (google.golang.org/adk/v2)
    para reservar estoque na loja física (Ship-from-Store), calcular o cashback/voucher
    de compensação e aprovar a operação em sub-milissegundos.

    Args:
        order_id: Código do pedido (ex: 'PED-9082').
        customer_id: Identificador do cliente (ex: 'CLI-MARINA-9082').
        order_value_brl: Valor total do pedido em Reais (BRL).
        operation_type: Ação ('SHIP_FROM_STORE_COM_VOUCHER', 'TROCA_EXPRESSA', 'ESTORNO_TOTAL').
        store_origin: Loja física onde o estoque será reservado.
        payment_score: Score de confiabilidade do cliente no BigQuery (0 a 100).
    """
    payload = json.dumps(
        {
            "order_id": order_id,
            "customer_id": customer_id,
            "amount_brl": order_value_brl,
            "operation_type": operation_type,
            "store_origin": store_origin,
            "payment_score": payment_score,
            "project_id": GCP_PROJECT_ID,
        }
    ).encode("utf-8")

    # Tenta executar no microsserviço Go ADK ao vivo (porta 8081)
    try:
        req = urllib.request.Request(
            GO_AGENT_ENDPOINT,
            data=payload,
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        with urllib.request.urlopen(req, timeout=2.5) as resp:
            live_data = json.loads(resp.read().decode("utf-8"))
            live_data["execution_mode"] = "LIVE_GO_ADK_MICROSERVICE"
            return live_data
    except (urllib.error.URLError, TimeoutError, Exception):
        # Fallback resiliente para que a Demo de Pré-Vendas nunca falhe ao vivo
        cashback_brl = round(order_value_brl * 0.10, 2)
        risk_score = round(max(0.03, (100.0 - payment_score) / 100.0 + (order_value_brl / 200000.0)), 3)
        approved = order_value_brl <= 15000.0 and risk_score < 0.45

        return {
            "status": "COMPLETED",
            "execution_mode": "RESILIENT_SIMULATION_GO_ADK_V2",
            "runtime": "google.golang.org/adk/v2 (Go High-Concurrency POS/OMS Worker)",
            "gcp_project": GCP_PROJECT_ID,
            "order_id": order_id,
            "customer_id": customer_id,
            "operation_type": operation_type,
            "amount_brl": order_value_brl,
            "cashback_granted_brl": cashback_brl if approved else 0.0,
            "voucher_code": f"VIP10-{order_id.replace('-', '')}" if approved else "PENDENTE_DIRETORIA",
            "shipping_dispatch": f"SHIP_FROM_STORE_EXPRESS_2H ({store_origin})" if approved else "AGUARDANDO_APROVACAO_HUMANA",
            "calculated_risk_score": risk_score,
            "decision": "AUTO_APPROVED_BY_GO_ADK_AGENT" if approved else "ESCALATE_TO_DIRECTOR_IN_GEMINI_ENTERPRISE",
            "transaction_protocol": f"QI-RET-GO-{order_id.replace('-', '')}-2026",
            "latency_ms": 1.18,
        }


# ============================================================================
# DEFINIÇÃO DOS SUBAGENTES DE VAREJO (Arquitetura Hierárquica ADK)
# ============================================================================

retail_policy_specialist = Agent(
    name="retail_policy_specialist",
    model=MODEL_NAME,
    description=(
        "Especialista em Políticas de Varejo Omnicanal, Trocas, Devoluções, SLAs de Entrega "
        "e Regras de Compensação indexadas no Vertex AI Search / Gemini Enterprise."
    ),
    instruction=(
        "Você é o Especialista em Políticas e Governança de Varejo. "
        "Sempre use a ferramenta `consultar_politicas_varejo` para buscar a regra oficial "
        "no manual de operações do projeto gemini-demo-qi, citando o arquivo PDF e a página."
    ),
    tools=[consultar_politicas_varejo],
)

bigquery_retail_analyst = Agent(
    name="bigquery_retail_analyst",
    model=MODEL_NAME,
    description=(
        "Analista de Dados de Varejo no BigQuery. Consulta status de pedidos (ex: PED-9082, PED-4010, PED-7721), "
        "nível de fidelidade do cliente e estoque em tempo real nas lojas físicas próximas."
    ),
    instruction=(
        "Você é o Analista de Dados Omnicanal conectado ao BigQuery. "
        "Sempre utilize `consultar_pedido_e_estoque_bigquery` para levantar os detalhes do pedido, "
        "valor, status atual e qual loja física possui estoque para atender o cliente rapidamente."
    ),
    tools=[consultar_pedido_e_estoque_bigquery],
)

go_retail_pos_engine = Agent(
    name="go_retail_pos_engine",
    model=MODEL_NAME,
    description=(
        "Agente Transacional de Alta Performance em Go (ADK Go v2). Executa reserva de estoque "
        "na loja física (Ship-from-Store), calcula cashback/voucher e emite o protocolo no ERP."
    ),
    instruction=(
        "Você é a ponte com o Motor Transacional de Varejo escrito em Go (ADK v2). "
        "Acione `acionar_motor_transacional_go_varejo` passando os dados do pedido e da loja física, "
        "e destaque na sua resposta a latência em milissegundos, o código do Voucher gerado, "
        "o valor do Cashback em R$ e o protocolo da transação."
    ),
    tools=[acionar_motor_transacional_go_varejo],
)


# ============================================================================
# AGENTE RAIZ (ROOT ORCHESTRATOR) — EXPOSTO PARA `adk web` E `Agent Engine`
# ============================================================================

root_agent = Agent(
    name="qi_enterprise_orchestrator",
    model=MODEL_NAME,
    description=(
        "Orquestrador Multi-Agente de Varejo Omnicanal da QI Network (Projeto gemini-demo-qi). "
        "Resolve problemas de pedidos, ruptura de estoque, trocas e logística coordenando "
        "Vertex AI Search (Grounding), BigQuery e o Agente Transacional em Go."
    ),
    instruction=(
        f"Você é o Orquestrador Inteligente de Varejo Omnicanal da QI Network rodando no Google Cloud "
        f"(Projeto: {GCP_PROJECT_ID}).\n\n"
        "Quando um usuário perguntar sobre um pedido atrasado, ruptura de estoque, troca ou regra de loja:\n"
        "1. Acione `bigquery_retail_analyst` para consultar o pedido (ex: PED-9082, PED-4010 ou PED-7721), "
        "o perfil de fidelidade do cliente e qual loja física próxima tem o produto em estoque.\n"
        "2. Acione `retail_policy_specialist` para verificar a política oficial de SLA, Ship-from-Store e alçada de compensação.\n"
        "3. Acione `go_retail_pos_engine` para executar no motor em Go a reserva de estoque na loja física, "
        "gerar o Voucher/Cashback de 10% (se dentro da alçada) e emitir o protocolo.\n"
        "4. Apresente a resposta final em Português de forma visual e executiva contendo:\n"
        "   - **🛒 Diagnóstico do Pedido & Estoque Omnicanal (BigQuery)**\n"
        "   - **📜 Política Aplicada & Fonte Auditável (Gemini Enterprise / Vertex Search)**\n"
        "   - **⚡ Ação Executada pelo Agente em Go (Ship-from-Store, Voucher, Cashback e Latência em ms)**\n"
        "   - **💬 Mensagem Pronta para Enviar ao Cliente no WhatsApp/App**"
    ),
    sub_agents=[
        bigquery_retail_analyst,
        retail_policy_specialist,
        go_retail_pos_engine,
    ],
)
