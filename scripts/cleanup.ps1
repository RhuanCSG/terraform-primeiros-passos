# Destrói recursos Terraform e limpa arquivos de estado locais
# Uso: .\scripts\cleanup.ps1 <caminho_do_exercicio>
# Exemplo: .\scripts\cleanup.ps1 src\fase-1-hello-aws

param(
    [Parameter(Mandatory=$true)]
    [string]$TargetDir
)

if (-not (Test-Path $TargetDir -PathType Container)) {
    Write-Host "❌ Diretório não encontrado: $TargetDir" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Terraform Cleanup — $TargetDir"                  -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Este script irá destruir todos os recursos Terraform em:" -ForegroundColor Yellow
Write-Host "  $TargetDir"
Write-Host ""

$confirm = Read-Host "Tem certeza? Digite 'sim' para confirmar"

if ($confirm -ne "sim") {
    Write-Host "Operação cancelada."
    exit 0
}

Set-Location $TargetDir

# Verifica se há estado inicializado
if (-not (Test-Path ".terraform" -PathType Container)) {
    Write-Host "Nenhum estado Terraform encontrado. Rodando init primeiro..." -ForegroundColor Yellow
    tflocal init -reconfigure
}

# Destroy
Write-Host ""
Write-Host "Executando destroy..."
tflocal destroy -auto-approve

# Limpar arquivos locais
Write-Host ""
Write-Host "Limpando arquivos locais..."

@("terraform.tfstate", "terraform.tfstate.backup", ".terraform.tfstate.lock.info") | ForEach-Object {
    if (Test-Path $_) {
        Remove-Item $_ -Force
        Write-Host "  removido: $_"
    }
}

# Nota: não remover .terraform/ — o próximo init seria mais lento
Write-Host ""
Write-Host "✅ Cleanup concluído." -ForegroundColor Green
Write-Host ""
