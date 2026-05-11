# Providers

Providers são plugins que permitem ao Terraform se comunicar com APIs externas — AWS, Azure, GCP, GitHub, Datadog, e centenas de outros. Sem um provider, o Terraform não sabe como criar nenhum recurso.

---

## Como Funcionam os Providers

```mermaid
graph LR
    TF[Terraform Core] -->|chama| P[AWS Provider]
    P -->|API calls| AWS[AWS API]
    AWS -->|resposta| P
    P -->|resultado| TF
```

1. Você declara qual provider usar e em qual versão
2. `terraform init` baixa o plugin do provider
3. O provider traduz seus blocos `resource` em chamadas de API

---

## Declarando o AWS Provider

Em qualquer projeto Terraform com AWS, você precisa de dois blocos:

```hcl
# Declara a dependência do provider e sua versão
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configura o provider (região, autenticação, etc.)
provider "aws" {
  region = "us-east-1"
}
```

!!! tip "O que significa `~> 5.0`?"
    O operador `~>` (pessimistic constraint) significa "qualquer versão >= 5.0 e < 6.0". Isso garante compatibilidade com patches e minor releases sem aceitar breaking changes de uma versão major.

---

## Autenticação com AWS

O AWS Provider usa a **cadeia de credenciais padrão da AWS**. Ele busca credenciais nesta ordem:

1. Variáveis de ambiente (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
2. Perfil do AWS CLI (`~/.aws/credentials`)
3. IAM Role (quando rodando em EC2, Lambda, ECS, etc.)

!!! danger "NUNCA faça isso"
    ```hcl
    # ❌ ERRADO — hardcodar credenciais no código
    provider "aws" {
      region     = "us-east-1"
      access_key = "AKIAIOSFODNN7EXAMPLE"   # ← NUNCA!
      secret_key = "wJalrXUtnFEMI/K7MDENG" # ← NUNCA!
    }
    ```
    Credenciais hardcodadas vão parar no git e são um risco de segurança gravíssimo.

**Modo correto — variável de ambiente:**

=== "Linux / macOS"
    ```bash
    export AWS_PROFILE=meu-perfil-aws
    export AWS_DEFAULT_REGION=us-east-1
    terraform apply
    ```

=== "PowerShell"
    ```powershell
    $env:AWS_PROFILE = "meu-perfil-aws"
    $env:AWS_DEFAULT_REGION = "us-east-1"
    terraform apply
    ```

**Ou especificar o perfil no provider (sem segredos no código):**
```hcl
provider "aws" {
  region  = "us-east-1"
  profile = "meu-perfil-aws"
}
```

---

## Provider para LocalStack

Nas Fases 1–4, usamos o `tflocal` que configura os endpoints automaticamente. Mas para entender o que acontece por baixo, o provider ficaria assim:

```hcl
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"  # LocalStack aceita qualquer valor
  secret_key                  = "test"

  # Redireciona todas as chamadas para o LocalStack local
  endpoints {
    s3  = "http://localhost:4566"
    ec2 = "http://localhost:4566"
    iam = "http://localhost:4566"
    # ... e assim por diante
  }

  # Desativa verificações desnecessárias para ambiente local
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}
```

O `tflocal` faz exatamente isso automaticamente. Você escreve código como se fosse AWS real, e o wrapper redireciona para o LocalStack.

---

## O Arquivo `.terraform.lock.hcl`

Quando você roda `terraform init`, o Terraform cria um arquivo `.terraform.lock.hcl`:

```hcl
provider "registry.terraform.io/hashicorp/aws" {
  version     = "5.31.0"
  constraints = "~> 5.0"
  hashes = [
    "h1:abc123...",
  ]
}
```

Este arquivo **deve ser commitado no git**. Ele garante que todos no time (e o CI/CD) usem exatamente a mesma versão do provider, assim como um `package-lock.json` no Node.js.

---

## Múltiplos Providers

É possível usar múltiplos providers em um mesmo projeto, inclusive duas instâncias do mesmo provider com aliases:

```hcl
# Provider padrão — us-east-1
provider "aws" {
  region = "us-east-1"
}

# Provider alternativo — eu-west-1
provider "aws" {
  alias  = "europe"
  region = "eu-west-1"
}

# Usar o provider alternativo em um recurso específico
resource "aws_s3_bucket" "backup_europe" {
  provider = aws.europe
  bucket   = "meu-backup-eu"
}
```

---

## Próximo

➡️ [Ciclo de Vida](lifecycle.md) — agora vamos colocar a mão na massa e executar nosso primeiro `terraform apply`.
