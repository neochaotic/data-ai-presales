// Package main implementa o Microsserviço e Agente Transacional de Alta Performance em Go
// para o projeto GCP `gemini-demo-qi`, focado no cenário de Varejo Omnicanal (OMS/POS).
//
// Ele expõe o endpoint `/api/v1/evaluate` (porta 8081) consumido pelo Orquestrador ADK Python
// via protocolo HTTP/A2A, demonstrando como times de Backend em Go (alta vazão para Black Friday)
// e IA em Python colaboram na arquitetura Vertex AI Agent Engine + Gemini Enterprise.
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"math"
	"net/http"
	"os"
	"strings"
	"time"
)

// TransactionRequest representa o payload de Varejo recebido do Orquestrador ADK Python.
type TransactionRequest struct {
	OrderID       string  `json:"order_id"`
	CustomerID    string  `json:"customer_id"`
	AmountBRL     float64 `json:"amount_brl"`
	OperationType string  `json:"operation_type"`
	StoreOrigin   string  `json:"store_origin"`
	PaymentScore  float64 `json:"payment_score"`
	ProjectID     string  `json:"project_id"`
}

// TransactionResponse representa a decisão determinística e de baixa latência do Agente em Go.
type TransactionResponse struct {
	Status              string  `json:"status"`
	Runtime             string  `json:"runtime"`
	GCPProject          string  `json:"gcp_project"`
	OrderID             string  `json:"order_id"`
	CustomerID          string  `json:"customer_id"`
	OperationType       string  `json:"operation_type"`
	AmountBRL           float64 `json:"amount_brl"`
	CashbackGrantedBRL  float64 `json:"cashback_granted_brl"`
	VoucherCode         string  `json:"voucher_code"`
	ShippingDispatch    string  `json:"shipping_dispatch"`
	CalculatedRiskScore float64 `json:"calculated_risk_score"`
	Decision            string  `json:"decision"`
	TransactionProtocol string  `json:"transaction_protocol"`
	LatencyMs           float64 `json:"latency_ms"`
	TimestampUTC        string  `json:"timestamp_utc"`
}

func evaluateHandler(w http.ResponseWriter, r *http.Request) {
	start := time.Now()

	if r.Method != http.MethodPost {
		http.Error(w, "Método não permitido. Use POST.", http.StatusMethodNotAllowed)
		return
	}

	var req TransactionRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, fmt.Sprintf("Payload inválido: %v", err), http.StatusBadRequest)
		return
	}

	if req.ProjectID == "" {
		req.ProjectID = os.Getenv("GOOGLE_CLOUD_PROJECT")
		if req.ProjectID == "" {
			req.ProjectID = "gemini-demo-qi"
		}
	}
	if req.OrderID == "" {
		req.OrderID = "PED-9082"
	}
	if req.StoreOrigin == "" {
		req.StoreOrigin = "Loja Física #12 - Shopping Ibirapuera"
	}

	// Motor determinístico de Varejo Omnicanal em Go (cálculo em microsegundos para suportar escala de Black Friday)
	baseRisk := (100.0 - req.PaymentScore) / 100.0
	exposureFactor := req.AmountBRL / 200000.0
	riskScore := math.Max(0.03, math.Round((baseRisk+exposureFactor)*1000)/1000)

	cleanOrder := strings.ReplaceAll(strings.ToUpper(req.OrderID), "-", "")
	decision := "AUTO_APPROVED_BY_GO_ADK_AGENT"
	cashback := math.Round((req.AmountBRL*0.10)*100) / 100
	voucher := fmt.Sprintf("VIP10-%s", cleanOrder)
	dispatch := fmt.Sprintf("SHIP_FROM_STORE_EXPRESS_2H (%s)", req.StoreOrigin)

	// Regra de alçada do Varejo: pedidos acima de R$ 15.000 ou risco >= 0.45 sobem para aprovação no Gemini Enterprise
	if req.AmountBRL > 15000.0 || riskScore >= 0.45 {
		decision = "ESCALATE_TO_DIRECTOR_IN_GEMINI_ENTERPRISE"
		cashback = 0.0
		voucher = "PENDENTE_APROVACAO_DIRETORIA"
		dispatch = "AGUARDANDO_LIBERACAO_ALÇADA_SUPERIOR"
	}

	protocol := fmt.Sprintf("QI-RET-GO-%s-%d", cleanOrder, time.Now().Unix()%10000)
	elapsedMs := float64(time.Since(start).Microseconds()) / 1000.0

	resp := TransactionResponse{
		Status:              "COMPLETED",
		Runtime:             "google.golang.org/adk/v2 (Go High-Concurrency POS/OMS Worker)",
		GCPProject:          req.ProjectID,
		OrderID:             req.OrderID,
		CustomerID:          req.CustomerID,
		OperationType:       req.OperationType,
		AmountBRL:           req.AmountBRL,
		CashbackGrantedBRL:  cashback,
		VoucherCode:         voucher,
		ShippingDispatch:    dispatch,
		CalculatedRiskScore: riskScore,
		Decision:            decision,
		TransactionProtocol: protocol,
		LatencyMs:           elapsedMs,
		TimestampUTC:        time.Now().UTC().Format(time.RFC3339),
	}

	log.Printf("[GO-RETAIL-ADK] Order=%s | Customer=%s | Value=R$%.2f | Cashback=R$%.2f | Voucher=%s | Decision=%s | Latency=%.3fms",
		req.OrderID, req.CustomerID, req.AmountBRL, cashback, voucher, decision, elapsedMs)

	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(resp)
}

func healthHandler(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	_, _ = w.Write([]byte(`{"status":"UP","agent":"qi-go-retail-adk","project":"gemini-demo-qi"}`))
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8081"
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/api/v1/evaluate", evaluateHandler)
	mux.HandleFunc("/healthz", healthHandler)

	log.Printf("🛒 [gemini-demo-qi] Agente de Varejo Omnicanal Go (ADK v2) ouvindo em http://localhost:%s/api/v1/evaluate", port)
	if err := http.ListenAndServe(":"+port, mux); err != nil {
		log.Fatalf("Erro ao iniciar servidor Go ADK: %v", err)
	}
}
