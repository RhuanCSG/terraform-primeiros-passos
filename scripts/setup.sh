#!/usr/bin/env bash
# Verifica se todos os pré-requisitos estão instalados e configurados

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}✅ $1${NC}"; }
fail() { echo -e "${RED}❌ $1${NC}"; ERRORS=$((ERRORS + 1)); }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }

ERRORS=0

echo ""
echo "=================================================="
echo "  Primeiros passos Terraform — Verificação de Setup"
echo "=================================================="
echo ""

# --- Terraform ---
echo "[ Terraform ]"
if command -v terraform &>/dev/null; then
    TF_VERSION=$(terraform version -json 2>/dev/null | grep -o '"terraform_version":"[^"]*"' | cut -d'"' -f4)
    pass "Terraform instalado: v${TF_VERSION}"

    MAJOR=$(echo "$TF_VERSION" | cut -d. -f1)
    MINOR=$(echo "$TF_VERSION" | cut -d. -f2)
    if [ "$MAJOR" -lt 1 ] || { [ "$MAJOR" -eq 1 ] && [ "$MINOR" -lt 9 ]; }; then
        warn "Versão mínima recomendada: 1.9.x (atual: ${TF_VERSION})"
    fi
else
    fail "Terraform não encontrado. Instale em: https://developer.hashicorp.com/terraform/install"
fi

# --- tflocal ---
echo ""
echo "[ tflocal (wrapper para LocalStack) ]"
if command -v tflocal &>/dev/null; then
    pass "tflocal instalado"
else
    fail "tflocal não encontrado. Instale com: pip install terraform-local"
fi

# --- Docker ---
echo ""
echo "[ Docker ]"
if command -v docker &>/dev/null; then
    if docker info &>/dev/null 2>&1; then
        DOCKER_VERSION=$(docker --version | awk '{print $3}' | tr -d ',')
        pass "Docker instalado e rodando: v${DOCKER_VERSION}"
    else
        fail "Docker instalado mas não está rodando. Inicie o Docker Desktop."
    fi
else
    fail "Docker não encontrado. Instale em: https://www.docker.com/products/docker-desktop"
fi

# --- LocalStack ---
echo ""
echo "[ LocalStack ]"
if command -v localstack &>/dev/null; then
    LS_VERSION=$(localstack --version 2>/dev/null || echo "desconhecida")
    pass "LocalStack CLI instalado: v${LS_VERSION}"

    if curl -s --max-time 3 http://localhost:4566/_localstack/health &>/dev/null; then
        pass "LocalStack está rodando em localhost:4566"
    else
        warn "LocalStack não está rodando. Inicie com: localstack start -d"
    fi
else
    fail "LocalStack não encontrado. Instale com: pip install localstack"
fi

# --- AWS CLI ---
echo ""
echo "[ AWS CLI ]"
if command -v aws &>/dev/null; then
    AWS_VERSION=$(aws --version 2>&1 | awk '{print $1}' | cut -d'/' -f2)
    pass "AWS CLI instalado: v${AWS_VERSION}"

    if aws configure --profile localstack list &>/dev/null 2>&1; then
        pass "Perfil 'localstack' configurado no AWS CLI"
    else
        warn "Perfil 'localstack' não encontrado. Configure com:"
        warn "  aws configure --profile localstack"
        warn "  (use 'test' para access key e secret key)"
    fi
else
    fail "AWS CLI não encontrado. Instale em: https://aws.amazon.com/cli/"
fi

# --- Git ---
echo ""
echo "[ Git ]"
if command -v git &>/dev/null; then
    GIT_VERSION=$(git --version | awk '{print $3}')
    pass "Git instalado: v${GIT_VERSION}"

    if git rev-parse --git-dir &>/dev/null 2>&1; then
        pass "Repositório Git inicializado"
    else
        warn "Este diretório não é um repositório Git. Execute: git init"
    fi
else
    fail "Git não encontrado. Instale em: https://git-scm.com/"
fi

# --- Python / pip (para MkDocs) ---
echo ""
echo "[ Python + MkDocs ]"
if command -v python3 &>/dev/null || command -v python &>/dev/null; then
    PY_CMD=$(command -v python3 || command -v python)
    PY_VERSION=$($PY_CMD --version 2>&1 | awk '{print $2}')
    pass "Python instalado: v${PY_VERSION}"

    if python3 -c "import mkdocs" &>/dev/null 2>&1 || python -c "import mkdocs" &>/dev/null 2>&1; then
        pass "MkDocs instalado"
    else
        warn "MkDocs não encontrado. Instale com: pip install mkdocs-material"
    fi
else
    warn "Python não encontrado. Instale para usar o MkDocs."
fi

# --- Resultado final ---
echo ""
echo "=================================================="
if [ "$ERRORS" -eq 0 ]; then
    echo -e "${GREEN}  Tudo pronto! Você pode começar a Fase 1.${NC}"
    echo ""
    echo "  Para iniciar a documentação:"
    echo "  mkdocs serve"
else
    echo -e "${RED}  ${ERRORS} problema(s) encontrado(s). Corrija antes de prosseguir.${NC}"
fi
echo "=================================================="
echo ""
