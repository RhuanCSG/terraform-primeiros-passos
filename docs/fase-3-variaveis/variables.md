# Variables (Variáveis de Input)

Variáveis permitem que seu código aceite parâmetros externos — o mesmo código pode criar infraestrutura para `dev` ou `prod` apenas passando valores diferentes.

---

## Declaração

```hcl
# variables.tf

variable "bucket_name" {
  type        = string
  description = "Nome do bucket S3 a ser criado"
}
```

Os campos `type` e `description` são opcionais, mas são boas práticas — `description` documenta o propósito, `type` previne erros.

---

## Campos de uma Variable

| Campo | Obrigatório | Descrição |
|---|---|---|
| `type` | Não | Tipo do valor (`string`, `number`, `bool`, `list`, `map`, etc.) |
| `description` | Não | Documentação para quem usa o módulo |
| `default` | Não | Valor padrão (torna a variável opcional) |
| `validation` | Não | Regras de validação customizadas |
| `sensitive` | Não | Oculta o valor nos logs do plan/apply |

---

## Tipos de Dados

```hcl
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_count" {
  type    = number
  default = 2
}

variable "enable_versioning" {
  type    = bool
  default = true
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "tags" {
  type = map(string)
  default = {
    ManagedBy = "terraform"
  }
}

# Objeto estruturado (útil para configurações complexas)
variable "database_config" {
  type = object({
    engine         = string
    instance_class = string
    storage_gb     = number
  })
  default = {
    engine         = "postgres"
    instance_class = "db.t3.micro"
    storage_gb     = 20
  }
}
```

---

## Validações

Valide as entradas antes de chegar na API:

```hcl
variable "environment" {
  type        = string
  description = "Ambiente de deployment"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "O ambiente deve ser 'dev', 'staging' ou 'prod'."
  }
}

variable "bucket_name" {
  type = string

  validation {
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "Nome do bucket deve ter entre 3 e 63 caracteres."
  }
}
```

---

## Usando Variáveis no Código

```hcl
resource "aws_s3_bucket" "app" {
  bucket = var.bucket_name  # ← acessa com var.<nome>
}
```

---

## Como Passar Valores

### 1. Arquivo `terraform.tfvars` (mais comum)

```hcl
# terraform.tfvars — NÃO commitado no git
bucket_name = "minha-empresa-dev-storage"
environment = "dev"
region      = "us-east-1"
```

```bash
terraform apply  # lê terraform.tfvars automaticamente
```

### 2. Arquivo `.tfvars` com nome customizado

```bash
terraform apply -var-file="prod.tfvars"
```

### 3. Linha de comando

```bash
terraform apply -var="environment=prod" -var="bucket_name=meu-bucket-prod"
```

### 4. Variável de ambiente

=== "Linux / macOS"
    ```bash
    export TF_VAR_environment=prod
    export TF_VAR_bucket_name=meu-bucket-prod
    terraform apply
    ```

=== "PowerShell"
    ```powershell
    $env:TF_VAR_environment = "prod"
    $env:TF_VAR_bucket_name = "meu-bucket-prod"
    terraform apply
    ```

### Ordem de precedência (maior prioridade primeiro)

1. `-var` e `-var-file` na linha de comando
2. `*.auto.tfvars` e `*.auto.tfvars.json`
3. `terraform.tfvars` e `terraform.tfvars.json`
4. Variáveis de ambiente `TF_VAR_*`
5. `default` na declaração da variável

---

## Variáveis Sensíveis

```hcl
variable "db_password" {
  type      = string
  sensitive = true  # ← oculta o valor nos logs
}
```

Com `sensitive = true`, o valor aparece como `(sensitive value)` no `plan` e no `apply`. **Atenção:** o valor ainda é armazenado em texto claro no estado — use AWS Secrets Manager para senhas em produção.

---

## Próximo

➡️ [Outputs](outputs.md)
