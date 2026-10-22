# 🚀 Data & AI Pre-Sales Kit — Google Cloud (`gemini-demo-qi`)

Bem-vindo ao repositório **Data & AI Pre-Sales** da **QI Network**, projetado para o projeto GCP **`gemini-demo-qi`** ([neochaotic/data-ai-presales](https://github.com/neochaotic/data-ai-presales)).

Este kit fornece uma estrutura **modular, reutilizável e 100% atualizada** para conduzir reuniões de Pré-Vendas (Discovery & Demo), elaborar Propostas Comerciais e acelerar a Implantação (Delivery) da pilha moderna de IA Agêntica do Google Cloud:

1. **Ato 1 — Fundação & Engenharia de Agentes (Vertex AI Platform + ADK Python/Go + Agent Engine)**
2. **Ato 2 — Experiência de Negócio & Governança (Gemini Enterprise / Agentspace)**
3. **Ato 3 — Aceleração de Engenharia de Software (Google Antigravity IDE, App 2.0 & SDK)**

---

## 📂 Estrutura do Repositório

```text
data-ai-presales/
├── README.md                                  # Visão geral e Quickstart (projeto gemini-demo-qi)
├── docs/
│   ├── 01-storytelling-playbook.md            # Narrativa executiva segmentada + Casos Genéricos por vertical
│   ├── 02-roteiro-demo-ui-e-automacao.md      # Guia híbrido: Automação (CLI) + Exploração Visual de UI
│   └── 03-template-proposta-e-implantacao.md  # Modelo de Proposta Comercial + Blueprint de Implantação
├── agents/
│   ├── python-orchestrator/                   # Agente Orquestrador Multi-Agente em Python (google-adk)
│   │   ├── agent.py
│   │   ├── requirements.txt
│   │   └── .env.example
│   └── go-microservice-agent/                 # Agente Transacional de Alta Performance em Go (adk/v2)
│       ├── main.go
│       └── go.mod
├── automation/
│   ├── setup-gemini-demo-qi.sh                # Script de bootstrap do projeto GCP gemini-demo-qi
│   └── Makefile                               # Atalhos para automação, UI local (adk web) e deploy
└── .agents/
    └── skills/
        └── presales-customizer/
            └── SKILL.md                       # Skill do Antigravity para adaptar a demo a qualquer cliente em 1 min
```

---

## ⚡ Quickstart (Projeto `gemini-demo-qi`)

### 1. Configurar o Projeto GCP e APIs (Automação)
```bash
cd automation
make init-gcp PROJECT_ID=gemini-demo-qi REGION=us-central1
```

### 2. Explorar a UI Visual de Agentes Localmente (`adk web`)
O **ADK Web UI** permite mostrar ao cliente o grafo de agentes em tempo real, inspecionar chamadas de ferramentas (Tools/MCP), latência e raciocínio passo a passo:
```bash
cd automation
make run-ui-python
# Acesse http://localhost:8000 no navegador para explorar a UI interativa!
```

### 3. Executar o Agente em Go (Microsserviço / A2A)
```bash
cd automation
make run-agent-go
```

### 4. Deploy Automatizado para o Vertex AI Agent Engine
```bash
cd automation
make deploy-agent-engine PROJECT_ID=gemini-demo-qi
```

---

## 🎯 Como Adaptar para um Novo Cliente em 2 Minutos (Usando o Antigravity)

Este repositório já inclui uma **Skill nativa do Google Antigravity** em `.agents/skills/presales-customizer/SKILL.md`.
Antes de entrar em uma call com um cliente, basta abrir o **Antigravity** e digitar no chat:

> *"Use a skill presales-customizer para adaptar os nossos casos genéricos, prompts do ADK e minuta de proposta para um cliente do setor de **[Varejo / Saúde / Financeiro / Manufatura]** focado em **[ Atendimento / Backoffice / Inteligência Comercial ]**."*
