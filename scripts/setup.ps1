# Verifica se todos os pré-requisitos estão instalados e configurados

$errors = 0

function Pass($msg) { Write-Host "✅ $msg" -ForegroundColor Green }
function Fail($msg) { Write-Host "❌ $msg" -ForegroundColor Red; $script:errors++ }
function Warn($msg) { Write-Host "⚠️  $msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Primeiros passos Terraform — Verificação de Setup"   -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# --- Terraform ---
Write-Host "[ Terraform ]"
$tf = Get-Command terraform -ErrorAction SilentlyContinue
if ($tf) {
    $tfVersion = (terraform version -json | ConvertFrom-Json).terraform_version
    Pass "Terraform instalado: v$tfVersion"

    $parts = $tfVersion -split '\.'
    if ([int]$parts[0] -lt 1 -or ([int]$parts[0] -eq 1 -and [int]$parts[1] -lt 9)) {
        Warn "Versão mínima recomendada: 1.9.x (atual: $tfVersion)"
    }
} else {
    Fail "Terraform não encontrado. Instale com: winget install HashiCorp.Terraform"
}

# --- tflocal ---
Write-Host ""
Write-Host "[ tflocal (wrapper para LocalStack) ]"
$tflocal = Get-Command tflocal -ErrorAction SilentlyContinue
if ($tflocal) {
    Pass "tflocal instalado"
} else {
    Fail "tflocal não encontrado. Instale com: pip install terraform-local"
}

# --- Docker ---
Write-Host ""
Write-Host "[ Docker ]"
$docker = Get-Command docker -ErrorAction SilentlyContinue
if ($docker) {
    $dockerRunning = docker info 2>$null
    if ($LASTEXITCODE -eq 0) {
        $dockerVersion = (docker --version) -replace 'Docker version ([^,]+).*', '$1'
        Pass "Docker instalado e rodando: v$dockerVersion"
    } else {
        Fail "Docker instalado mas não está rodando. Inicie o Docker Desktop."
    }
} else {
    Fail "Docker não encontrado. Instale em: https://www.docker.com/products/docker-desktop"
}

# --- LocalStack ---
Write-Host ""
Write-Host "[ LocalStack ]"
$ls = Get-Command localstack -ErrorAction SilentlyContinue
if ($ls) {
    $lsVersion = (localstack --version 2>$null) ?? "desconhecida"
    Pass "LocalStack CLI instalado: v$lsVersion"

    try {
        $health = Invoke-RestMethod -Uri "http://localhost:4566/_localstack/health" -TimeoutSec 3 -ErrorAction Stop
        Pass "LocalStack está rodando em localhost:4566"
    } catch {
        Warn "LocalStack não está rodando. Inicie com: localstack start -d"
    }
} else {
    Fail "LocalStack não encontrado. Instale com: pip install localstack"
}

# --- AWS CLI ---
Write-Host ""
Write-Host "[ AWS CLI ]"
$aws = Get-Command aws -ErrorAction SilentlyContinue
if ($aws) {
    $awsVersion = ((aws --version 2>&1) -split ' ')[0] -replace 'aws-cli/', ''
    Pass "AWS CLI instalado: v$awsVersion"

    aws configure --profile localstack list 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Pass "Perfil 'localstack' configurado no AWS CLI"
    } else {
        Warn "Perfil 'localstack' não encontrado. Configure com:"
        Warn "  aws configure --profile localstack"
        Warn "  (use 'test' para access key e secret key)"
    }
} else {
    Fail "AWS CLI não encontrado. Instale com: winget install Amazon.AWSCLI"
}

# --- Git ---
Write-Host ""
Write-Host "[ Git ]"
$git = Get-Command git -ErrorAction SilentlyContinue
if ($git) {
    $gitVersion = (git --version) -replace 'git version ', ''
    Pass "Git instalado: v$gitVersion"

    git rev-parse --git-dir 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Pass "Repositório Git inicializado"
    } else {
        Warn "Este diretório não é um repositório Git. Execute: git init"
    }
} else {
    Fail "Git não encontrado. Instale com: winget install Git.Git"
}

# --- Python / pip (para MkDocs) ---
Write-Host ""
Write-Host "[ Python + MkDocs ]"
$py = Get-Command python -ErrorAction SilentlyContinue
if ($py) {
    $pyVersion = (python --version 2>&1) -replace 'Python ', ''
    Pass "Python instalado: v$pyVersion"

    python -c "import mkdocs" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Pass "MkDocs instalado"
    } else {
        Warn "MkDocs não encontrado. Instale com: pip install mkdocs-material"
    }
} else {
    Warn "Python não encontrado. Instale com: winget install Python.Python.3"
}

# --- Resultado final ---
Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
if ($errors -eq 0) {
    Write-Host "  Tudo pronto! Você pode começar a Fase 1." -ForegroundColor Green
    Write-Host ""
    Write-Host "  Para iniciar a documentação:"
    Write-Host "  mkdocs serve"
} else {
    Write-Host "  $errors problema(s) encontrado(s). Corrija antes de prosseguir." -ForegroundColor Red
}
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
