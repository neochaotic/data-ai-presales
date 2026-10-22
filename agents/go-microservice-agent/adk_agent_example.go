//go:build adk_llm_example
// +build adk_llm_example

// Este arquivo demonstra a anatomia nativa de um Agente LLM construído diretamente
// com o SDK oficial `google.golang.org/adk/v2` em Go para apresentar a arquitetos
// e engenheiros de software durante a sessão técnica de Pré-Vendas.
package main

import (
	"context"
	"log"
	"os"

	"google.golang.org/adk/v2/agent/llmagent"
	"google.golang.org/adk/v2/model/gemini"
	"google.golang.org/adk/v2/tool"
	"google.golang.org/adk/v2/tool/geminitool"
	"google.golang.org/genai"
)

func buildNativeGoADKAgent(ctx context.Context) {
	projectID := os.Getenv("GOOGLE_CLOUD_PROJECT")
	if projectID == "" {
		projectID = "gemini-demo-qi"
	}

	// 1. Inicializa o modelo Gemini 2.5 Flash no Vertex AI (projeto gemini-demo-qi)
	model, err := gemini.NewModel(ctx, "gemini-2.5-flash", &genai.ClientConfig{
		Backend:  genai.BackendVertexAI,
		Project:  projectID,
		Location: "us-central1",
	})
	if err != nil {
		log.Fatalf("Falha ao inicializar modelo Gemini no Vertex AI: %v", err)
	}

	// 2. Define o Agente LLM em Go usando llmagent.New (ADK v2)
	transactionalAgent, err := llmagent.New(llmagent.Config{
		Name:  "qi_go_high_performance_agent",
		Model: model,
		Instruction: `Você é o Agente de Microsserviços de Alta Performance da QI Network (escrito em Go).
Sua responsabilidade é validar transações críticas, checar regras de SLA e retornar
decisões determinísticas com latência mínima para o Orquestrador Corporativo.`,
		Tools: []tool.Tool{
			geminitool.GoogleSearch{},
		},
	})
	if err != nil {
		log.Fatalf("Falha ao instanciar agente ADK Go: %v", err)
	}

	log.Printf("✅ Agente nativo Go ADK v2 inicializado com sucesso: %s (Projeto: %s)",
		transactionalAgent.Name(), projectID)
}
