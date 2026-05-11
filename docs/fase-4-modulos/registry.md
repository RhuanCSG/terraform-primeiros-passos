# Terraform Registry

O [Terraform Registry](https://registry.terraform.io/) é o repositório público de módulos da HashiCorp. Em vez de escrever tudo do zero, você pode usar módulos testados e mantidos pela comunidade.

---

## Por que Usar Módulos do Registry?

Módulos como o `terraform-aws-modules/vpc/aws` já estão em produção em milhares de empresas. Eles lidam com casos de borda que você levaria semanas para descobrir — por exemplo, configurações corretas de route tables para NAT Gateway em múltiplas AZs.

**Trade-off:**
- ✅ Econômiza tempo, segue boas práticas
- ⚠️ Você precisa ler a documentação para entender as variáveis
- ⚠️ Menos controle sobre a implementação interna

---

## Como Usar um Módulo do Registry

```hcl
module "vpc" {
  # fonte no formato: <namespace>/<módulo>/<provider>
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"   # ← sempre fixe a versão!

  name = "meu-projeto-dev"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true   # uma NAT por VPC (mais barato para dev)

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

Após adicionar o módulo, rode `terraform init` para baixá-lo:

```bash
terraform init

# Initializing modules...
# Downloading registry.terraform.io/terraform-aws-modules/vpc/aws 5.1.2 for vpc...
# - vpc in .terraform/modules/vpc
```

---

## Módulos Verificados vs. Não Verificados

No Registry, módulos com o ícone ✓ (Verified) foram revisados pela HashiCorp ou são de parceiros oficiais. Prefira sempre módulos verificados.

**Módulos AWS mais usados:**

| Módulo | Descrição |
|---|---|
| `terraform-aws-modules/vpc/aws` | VPC completa com subnets, route tables, NAT |
| `terraform-aws-modules/ec2-instance/aws` | Instâncias EC2 com boas práticas |
| `terraform-aws-modules/alb/aws` | Application Load Balancer |
| `terraform-aws-modules/rds/aws` | RDS com Multi-AZ, backups |
| `terraform-aws-modules/eks/aws` | Cluster Kubernetes gerenciado |
| `terraform-aws-modules/iam/aws` | Roles, policies, usuários IAM |
| `terraform-aws-modules/s3-bucket/aws` | S3 com encryption, logging, lifecycle |

---

## Módulos Locais vs. Registry

| | Módulo Local | Módulo do Registry |
|---|---|---|
| Controle total | ✅ | ❌ |
| Tempo de implementação | Alto | Baixo |
| Curva de aprendizado | Baixa (você escreveu) | Média (ler documentação) |
| Boas práticas embutidas | Você decide | ✅ Já incluídas |
| Atualização | Manual | Via `version` |
| Ideal para | Lógica específica do seu negócio | Infraestrutura padrão AWS |

**Estratégia recomendada:** Use módulos do Registry para infraestrutura comum (VPC, RDS, EKS). Escreva módulos locais para lógica de negócio específica.

---

## Versionamento

Sempre fixe a versão de módulos externos:

```hcl
# ❌ Sem versão — pode quebrar com atualizações
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
}

# ✅ Com versão fixada
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"   # aceita 5.x mas não 6.0
}
```

O arquivo `.terraform.lock.hcl` registra a versão exata baixada — commite-o no git.

---

## Próximo

➡️ [Fase 5 — Produção e Boas Práticas](../fase-5-producao/index.md)
