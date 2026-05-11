# Sintaxe HCL

HCL (HashiCorp Configuration Language) é a linguagem que o Terraform usa. Ela foi projetada para ser legível por humanos e fácil de editar, mas também processável por máquinas.

---

## Estrutura Básica: Blocos

Tudo em HCL é organizado em **blocos**. Um bloco tem:

1. Um **tipo** (ex: `resource`, `variable`, `output`)
2. Zero ou mais **labels** (identificadores entre aspas)
3. Um **corpo** com argumentos entre `{}`

```hcl
<tipo_do_bloco> "<label_1>" "<label_2>" {
  argumento = valor
}
```

Exemplo real:
```hcl
resource "aws_s3_bucket" "meu_bucket" {
  bucket = "meu-bucket-unico-123"
}
```

Aqui:
- `resource` → tipo do bloco
- `"aws_s3_bucket"` → tipo do recurso (definido pelo provider AWS)
- `"meu_bucket"` → nome local do recurso (você escolhe)
- `bucket = "..."` → argumento com seu valor

---

## Tipos de Blocos Principais

### `terraform`
Configurações do próprio Terraform (versão mínima, backend, providers requeridos):

```hcl
terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

### `provider`
Configuração do provider (autenticação, região, endpoints):

```hcl
provider "aws" {
  region = "us-east-1"
}
```

### `resource`
O bloco mais comum — define um recurso de infraestrutura a ser criado:

```hcl
resource "aws_s3_bucket" "meu_bucket" {
  bucket = "meu-bucket-unico-123"

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

### `data`
Busca dados de recursos **existentes** (não cria nada):

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
```

### `variable`
Define parâmetros de entrada:

```hcl
variable "bucket_name" {
  type        = string
  description = "Nome do bucket S3"
}
```

### `output`
Expõe valores após o apply:

```hcl
output "bucket_arn" {
  value = aws_s3_bucket.meu_bucket.arn
}
```

### `locals`
Calcula valores reutilizáveis internamente:

```hcl
locals {
  common_tags = {
    Project   = "zero-to-pro"
    ManagedBy = "terraform"
  }
}
```

---

## Tipos de Dados

| Tipo | Exemplo | Descrição |
|---|---|---|
| `string` | `"us-east-1"` | Texto |
| `number` | `3` | Número inteiro ou decimal |
| `bool` | `true` ou `false` | Booleano |
| `list(tipo)` | `["a", "b", "c"]` | Lista ordenada |
| `set(tipo)` | `toset(["a", "b"])` | Lista sem duplicatas |
| `map(tipo)` | `{ key = "value" }` | Mapa chave-valor |
| `object({...})` | `{ name = string }` | Estrutura tipada |
| `any` | — | Tipo dinâmico |

---

## Referências entre Recursos

Para referenciar um atributo de outro recurso, use a sintaxe:

```
<tipo_recurso>.<nome_local>.<atributo>
```

Exemplo:
```hcl
resource "aws_s3_bucket" "meu_bucket" {
  bucket = "meu-bucket-123"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.meu_bucket.id  # ← referência

  versioning_configuration {
    status = "Enabled"
  }
}
```

O Terraform usa essas referências para montar o **grafo de dependências** — ele sabe que deve criar o bucket antes de configurar o versionamento.

---

## Expressões e Interpolação

```hcl
# Interpolação de string
name = "projeto-${var.environment}"

# Expressão condicional (ternário)
instance_type = var.environment == "prod" ? "t3.large" : "t3.micro"

# For expression — lista
subnets = [for s in var.subnet_cidrs : s]

# For expression — mapa
tags = { for k, v in var.extra_tags : k => upper(v) }
```

---

## Comentários

```hcl
# Comentário de linha única

// Também funciona para linha única

/*
  Comentário
  de múltiplas linhas
*/
```

---

## Formatação

O Terraform tem um formatador oficial. Sempre execute antes de commitar:

```bash
terraform fmt
```

Isso garante indentação com 2 espaços e alinhamento de `=` em blocos do mesmo nível — padrão da comunidade.

---

## Próximo

➡️ [Providers](providers.md) — agora que você conhece a sintaxe, vamos entender como o Terraform se conecta à AWS.
