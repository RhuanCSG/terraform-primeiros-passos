#!/usr/bin/env bash
# Destrói recursos Terraform e limpa arquivos de estado locais
# Uso: bash scripts/cleanup.sh [caminho_do_exercicio]
# Exemplo: bash scripts/cleanup.sh src/fase-1-hello-aws

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TARGET_DIR="${1:-}"

if [ -z "$TARGET_DIR" ]; then
    echo -e "${RED}Uso: bash scripts/cleanup.sh <caminho_do_exercicio>${NC}"
    echo "Exemplo: bash scripts/cleanup.sh src/fase-1-hello-aws"
    exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}Diretório não encontrado: $TARGET_DIR${NC}"
    exit 1
fi

echo ""
echo "=================================================="
echo "  Terraform Cleanup — $TARGET_DIR"
echo "=================================================="
echo ""
echo -e "${YELLOW}Este script irá destruir todos os recursos Terraform em:${NC}"
echo "  $TARGET_DIR"
echo ""
read -rp "Tem certeza? Digite 'sim' para confirmar: " CONFIRM

if [ "$CONFIRM" != "sim" ]; then
    echo "Operação cancelada."
    exit 0
fi

cd "$TARGET_DIR"

# Verifica se há estado inicializado
if [ ! -d ".terraform" ]; then
    echo -e "${YELLOW}Nenhum estado Terraform encontrado. Rodando init primeiro...${NC}"
    tflocal init -reconfigure
fi

# Destroy
echo ""
echo "Executando destroy..."
tflocal destroy -auto-approve

# Limpar arquivos locais
echo ""
echo "Limpando arquivos locais..."

[ -f "terraform.tfstate" ]         && rm -f terraform.tfstate         && echo "  removido: terraform.tfstate"
[ -f "terraform.tfstate.backup" ]  && rm -f terraform.tfstate.backup  && echo "  removido: terraform.tfstate.backup"
[ -f ".terraform.tfstate.lock.info" ] && rm -f .terraform.tfstate.lock.info

# Nota: não remover .terraform/ — o próximo init seria mais lento
echo ""
echo -e "${GREEN}✅ Cleanup concluído.${NC}"
echo ""
