#!/usr/bin/env bash
# ============================================================================
# Publicação e Sincronização com o Repositório GitHub
# Repositório Alvo: https://github.com/neochaotic/data-ai-presales
# ============================================================================
set -euo pipefail

REPO_URL="${1:-https://github.com/neochaotic/data-ai-presales.git}"
BRANCH="${2:-main}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${ROOT_DIR}"

echo "🐙 Preparando repositório em ${ROOT_DIR} para envio a ${REPO_URL}..."

if [ ! -d ".git" ]; then
  git init
  git branch -M "${BRANCH}"
fi

if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "${REPO_URL}"
else
  git remote add origin "${REPO_URL}"
fi

cat << 'EOF' > .gitignore
.venv/
__pycache__/
*.pyc
.env
.DS_Store
EOF

git add .
git status

if git diff --cached --quiet; then
  echo "ℹ️  Nenhuma alteração pendente para commit."
else
  git commit -m "feat(presales): kit completo Vertex AI ADK (Python/Go), Gemini Enterprise e Antigravity - Caso Varejo (gemini-demo-qi)"
fi

echo "🚀 Enviando para ${REPO_URL} (branch: ${BRANCH})..."
git push -u origin "${BRANCH}"

echo "✅ Código publicado com sucesso em ${REPO_URL}!"
