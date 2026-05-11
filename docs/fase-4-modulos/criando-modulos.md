# Criando Módulos

Um módulo Terraform é simplesmente um diretório com arquivos `.tf`. Qualquer diretório é um módulo. A questão é como estruturá-lo bem para que seja fácil de usar e manter.

---

## Anatomia de um Módulo

```
modules/vpc/
├── main.tf        # recursos que o módulo cria
├── variables.tf   # interface de entrada (o que o consumidor precisa informar)
├── outputs.tf     # interface de saída (o que o consumidor pode usar)
└── versions.tf    # versões do Terraform e provider requeridas
```

---

## Exemplo Completo: Módulo VPC

### `modules/vpc/variables.tf`

```hcl
variable "name" {
  type        = string
  description = "Nome do projeto — usado como prefixo em todos os recursos"
}

variable "environment" {
  type        = string
  description = "Ambiente (dev, staging, prod)"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Ambiente deve ser dev, staging ou prod."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "Bloco CIDR da VPC (ex: 10.0.0.0/16)"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Lista de CIDRs para subnets públicas (uma por AZ)"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Lista de CIDRs para subnets privadas (uma por AZ)"
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "tags" {
  type        = map(string)
  description = "Tags adicionais a serem aplicadas em todos os recursos"
  default     = {}
}
```

### `modules/vpc/main.tf`

```hcl
locals {
  name_prefix = "${var.name}-${var.environment}"

  common_tags = merge(var.tags, {
    Name        = local.name_prefix
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-vpc" })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-igw" })
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-${count.index + 1}"
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-${count.index + 1}"
    Tier = "private"
  })
}
```

### `modules/vpc/outputs.tf`

```hcl
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID da VPC criada"
}

output "vpc_cidr" {
  value       = aws_vpc.main.cidr_block
  description = "Bloco CIDR da VPC"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "Lista de IDs das subnets públicas"
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "Lista de IDs das subnets privadas"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.main.id
  description = "ID do Internet Gateway"
}
```

---

## Consumindo o Módulo

```hcl
# dev/main.tf

module "vpc" {
  source = "../modules/vpc"   # caminho relativo ao módulo

  name        = "meu-projeto"
  environment = "dev"
  vpc_cidr    = "10.0.0.0/16"

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
}

# Usando outputs do módulo em outro recurso
resource "aws_security_group" "app" {
  vpc_id = module.vpc.vpc_id   # ← acessa output do módulo

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr]
  }
}
```

---

## Boas Práticas de Interface de Módulo

### Faça
- **Inputs opcionais com defaults sensatos** — o consumidor não deve ser forçado a passar tudo
- **Validações nas variáveis** — falhe cedo com mensagem clara
- **Outputs de todos os IDs e ARNs criados** — outros módulos vão precisar
- **Uma única responsabilidade** — módulo VPC cria rede, não EC2

### Evite
- **Módulos que criam recursos de tipos completamente diferentes** — difícil de testar e manter
- **Hardcodar valores** dentro do módulo — use variáveis
- **Expor recursos internos pelo estado** — use outputs definidos

---

## Próximo

➡️ [Terraform Registry](registry.md) — como usar módulos prontos e validados pela comunidade.
