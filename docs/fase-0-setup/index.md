# 00. Setup e Ambiente

Antes de escrever uma linha de Terraform, precisamos garantir que o ambiente está correto. Um setup bem feito evita horas de debug desnecessário.

---

## Pré-requisitos

Você precisará ter instalados:

| Ferramenta | Versão mínima | Para quê |
|---|---|---|
| Terraform | >= 1.9 | A ferramenta principal |
| Docker | >= 24.x | Para rodar o LocalStack |
| LocalStack CLI | >= 3.x | Simulador AWS local |
| `tflocal` | qualquer | Wrapper do Terraform para LocalStack |
| AWS CLI | >= 2.x | Interagir com LocalStack e AWS real |
| Git | >= 2.x | Controle de versão |

---

## 1. Instalando o Terraform

=== "Windows (Chocolatey)"
    ```powershell
    choco install terraform
    ```

=== "Windows (Winget)"
    ```powershell
    winget install HashiCorp.Terraform
    ```

=== "macOS (Homebrew)"
    ```bash
    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform
    ```

=== "Linux (apt)"
    ```bash
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install terraform
    ```

**Verificação:**
```bash
terraform version
# Terraform v1.9.x
```

---

## 2. Instalando o Docker

O LocalStack roda como container Docker. Se você ainda não tem o Docker:

- **Windows/Mac:** [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- **Linux:** siga o guia oficial em [docs.docker.com](https://docs.docker.com/engine/install/)

**Verificação:**
```bash
docker --version
# Docker version 24.x.x
```

---

## 3. Instalando o LocalStack

```bash
pip install localstack
```

**Subindo o LocalStack:**
```bash
localstack start -d
# LocalStack rodando em http://localhost:4566
```

**Verificação:**

=== "Linux / macOS"
    ```bash
    curl http://localhost:4566/_localstack/health
    # Deve retornar JSON com status dos serviços
    ```

=== "PowerShell"
    ```powershell
    Invoke-RestMethod http://localhost:4566/_localstack/health
    # Deve retornar JSON com status dos serviços
    ```

!!! tip "Dica"
    O LocalStack pode ser parado a qualquer momento com `localstack stop`. Os recursos simulados são efêmeros — reiniciar o LocalStack apaga tudo. Isso é intencional para fins de aprendizado.

---

## 4. Instalando o `tflocal`

O `tflocal` é um wrapper que substitui o comando `terraform` e redireciona automaticamente todos os endpoints para o LocalStack. Você usa exatamente os mesmos comandos, sem alterar seu código `.tf`.

```bash
pip install terraform-local
```

**Verificação:**
```bash
tflocal version
# Terraform v1.9.x (via tflocal)
```

---

## 5. Configurando o AWS CLI para LocalStack

O LocalStack aceita qualquer credencial fictícia. Criamos um perfil dedicado para não confundir com sua conta AWS real:

```bash
aws configure --profile localstack
# AWS Access Key ID: test
# AWS Secret Access Key: test
# Default region name: us-east-1
# Default output format: json
```

**Usando o perfil em comandos AWS CLI:**
```bash
aws --endpoint-url=http://localhost:4566 --profile localstack s3 ls
```

!!! warning "Atenção"
    O perfil `localstack` usa credenciais fictícias (`test`/`test`). **Nunca** use essas credenciais em uma conta AWS real. Para sua conta real, use `aws configure` sem `--profile localstack`.

---

## 6. Verificação Final

Execute o script de setup para confirmar que tudo está funcionando:

=== "Linux / macOS"
    ```bash
    bash scripts/setup.sh
    ```

=== "PowerShell"
    ```powershell
    .\scripts\setup.ps1
    ```

Se todos os checks passarem com ✅, você está pronto para a **Fase 1**.

---

## Próxima Fase

➡️ [01. Fundamentos HCL e Ciclo de Vida](../fase-1-fundamentos/index.md)
