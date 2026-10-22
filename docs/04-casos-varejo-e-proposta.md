# 🛒 Guia de Demo & Proposta: Casos de Varejo Omnicanal (Fáceis de Entender)

O setor de **Varejo e E-commerce** é o melhor "idioma universal" para Pré-Vendas de IA: **100% das pessoas na sala (seja o CEO de um banco, o diretor de um hospital ou o CTO de uma indústria) são consumidores no dia a dia**. Todos já passaram por um pedido atrasado, uma dúvida de troca na loja ou uma promoção de Black Friday.

Abaixo estão os **3 Casos de Varejo Autoexplicativos** já configurados no código do projeto **`gemini-demo-qi`**.

---

## 🎯 Os 3 Casos de Uso de Varejo (1 para cada Ato do Storytelling)

### Caso 1: "O Cliente Quer Trocar uma TV com Caixa Aberta" (Ato 2 — Gemini Enterprise UI)
* **A História (30 segundos):** O cliente chega na loja física (ou no chat) querendo trocar uma Smart TV de R$ 6.490 comprada há 12 dias porque "achou grande demais para a sala", mas a caixa já foi aberta. O vendedor novo não sabe se pode aceitar ou não.
* **O que Mostrar na UI do Gemini Enterprise:**
  * O vendedor digita na busca do Gemini Enterprise:
    > 💬 **Prompt para Copiar:** `"Qual é a política de troca para produtos com caixa aberta após 7 dias? Clientes VIP/Diamante possuem exceção?"`
  * **Resultado Visual:** O Gemini Enterprise lê o manual oficial (`gs://gemini-demo-qi-retail-kb/manual-operacoes-omnicanal-2026.md`), mostra a citação exata da página e responde: *"Pelo CDC são 7 dias para compras online, mas para Clientes Ouro e Diamante a loja concede 30 dias mesmo com embalagem aberta, desde que sem avaria física."*

---

### Caso 2: "Meu Pedido Atrasou por Falta de Estoque no CD!" (Ato 1 — Vertex AI + ADK Python & Go na UI do `adk web`)
* **A História (30 segundos):** A cliente VIP **Marina Silva** comprou uma **Smart TV 65" OLED (`#PED-9082`)** para receber ontem, mas acabou o estoque no Centro de Distribuição (Ruptura). Em uma empresa comum, ela receberia um e-mail frio cancelando a compra e perderia a venda. Na nossa arquitetura Agêntica, os agentes salvam a venda sozinhos!
* **Como os 3 Agentes Trabalham Juntos na UI do `adk web` (`http://localhost:8000`):**
  1. **Agente Python (`bigquery_retail_analyst`):** Vai no BigQuery (`gemini-demo-qi.retail_omnicanal.orders_and_inventory_360`), descobre que a Marina é **Cliente Diamante** e encontra **4 unidades da mesma TV paradas na Loja Física do Shopping Ibirapuera**, a apenas 3,2 km da casa dela!
  2. **Agente Python (`retail_policy_specialist`):** Consulta o manual de operações e valida a regra: *"Cliente Diamante com ruptura no CD tem direito a envio expresso em 2h saindo da loja física mais próxima (Ship-from-Store) + 10% de Cashback automático."*
  3. **Agente Go (`go_retail_pos_engine` — ADK Go v2):** É acionado para fazer a transação pesada: em **~1 milissegundo**, calcula o risco, valida que o pedido (R$ 6.490) está abaixo do teto de aprovação automática (R$ 15.000), reserva a TV na loja do Ibirapuera, credita **R$ 649,00 de Cashback** e gera o cupom **`VIP10-PED9082`**!

* **Prompts Prontos para Demonstrar Ao Vivo no `adk web`:**
  * **Cenário A — Aprovação Automática em 1ms (Cliente B2C VIP):**
    > 💬 **Prompt 1 (Copiar e Colar):** `"O pedido PED-9082 da cliente Marina está atrasado por ruptura no CD. Consulte os dados no BigQuery, verifique a política de varejo e acione o agente em Go para resolver com envio da loja mais próxima e voucher."`
  * **Cenário B — Governança e Alçada Humana (Pedido Corporativo B2B de Alto Valor):**
    > 💬 **Prompt 2 (Copiar e Colar):** `"Analise o pedido corporativo PED-7721 (Lote de 15 Ar-Condicionados de R$ 54.000) que pediu estorno total e tente aprovar no motor em Go."`
    *(Mostre na UI que o Agente em Go **bloqueia a aprovação automática** porque passa do limite de R$ 15.000 e escala para o Diretor aprovar no Gemini Enterprise! Os executivos adoram ver esse controle de governança).*

---

### Caso 3: "Subir uma Regra de Black Friday em 2 Minutos" (Ato 3 — Google Antigravity IDE / App 2.0)
* **A História (30 segundos):** Chegou a sexta-feira da Black Friday às 10h da manhã. O Diretor Comercial liga para a TI: *"Precisamos aumentar o Cashback de compensação de 10% para 15% e subir a alçada automática do motor em Go de R$ 15.000 para R$ 25.000 agora!"*
* **O que Mostrar na UI do Google Antigravity:**
  * Abra o Chat Canvas do **Antigravity** e digite:
    > 💬 **Prompt para o Antigravity:** `"Estamos em campanha de Black Friday: atualize a política em @agents/python_orchestrator/agent.py e o cálculo no motor em Go em @agents/go-microservice-agent/main.go para aumentar o cashback automático de 10% para 15% e o limite de alçada de R$ 15.000 para R$ 25.000."`
  * O cliente vê o Antigravity editar **Python e Go ao mesmo tempo** com Diff Visual (verde/vermelho), sem quebrar nada, pronto para republicar no Vertex AI Agent Engine!

---

## 🔄 Como Conectar o Exemplo de Varejo a Qualquer Outro Setor ("A Ponte de Vendas")

Mesmo que o seu cliente não seja do Varejo, use a demo de Varejo porque todos entendem, e no final faça esta tradução de 10 segundos:

* **Se o cliente for Banco / Seguradora:** *"Viu como o agente cruzou o pedido `#PED-9082` no BigQuery, leu a regra no PDF e aprovou o cashback no motor Go até R$ 15 mil? No seu banco, troque 'Pedido Atrasado' por **'Análise de Sinistro ou Disputa de PIX'** — a arquitetura é exatamente a mesma!"*
* **Se o cliente for Saúde / Hospital / Operadora:** *"No seu cenário, troque 'Pedido com Ruptura' por **'Autorização de Guia Médica (TISS)'**, onde o Python checa a carência no banco, lê o protocolo clínico da ANS e o Go libera a senha em 1 segundo."*
* **Se o cliente for Indústria / Logística:** *"Na sua fábrica, troque a 'Loja Física mais próxima' por **'Fornecedor Homologado ou Galpão Regional'** quando falta matéria-prima na linha de produção."*

---

## 📄 Minuta de Proposta Comercial — Varejo Omnicanal (`gemini-demo-qi`)

### Escopo da Proposta: **Plataforma Agêntica de Operações & Atendimento Omnicanal**
1. **Pilar 1 — Assistente de Loja & Backoffice (Gemini Enterprise):**
   * Indexação de manuais operacionais, catálogos técnicos de produtos, regras promocionais e normas do PROCON/CDC com citações auditáveis.
2. **Pilar 2 — Orquestrador de Salva-Vendas & Logística (Vertex AI Agent Engine + ADK Python/Go):**
   * Agente conectado ao **BigQuery** (Pedidos + Estoque de Lojas) e **ERP/OMS** (via Agente em Go de baixa latência) para automação de *Ship-from-Store*, trocas expressas e emissão governada de vouchers.
3. **Pilar 3 — Aceleração Contínua de Campanhas (Google Antigravity):**
   * Capacitação da equipe de engenharia para criação rápida de ferramentas MCP e regras sazonais (Black Friday, Natal, Dia das Mães).

### Retorno sobre Investimento (ROI) Esperado no Varejo
* **Redução de 40% a 65% no Cancelamento por Ruptura (Save-the-Sale):** Conversão automática de rupturas do CD em entregas expressas via loja física.
* **Redução de 70% no Tempo Médio de Atendimento (TMA):** Resolução no primeiro contato sem escalar para Nível 2.
* **Zero Risco de Fraude de Alçada:** Travas determinísticas em Go + proteção contra *Prompt Injection* via **Vertex AI Model Armor**.
