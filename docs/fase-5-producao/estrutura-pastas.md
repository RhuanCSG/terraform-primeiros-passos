# Estrutura Profissional de Repositório

Como você organiza um repositório Terraform determina se ele escala para um time de 2 ou 20 pessoas. Existem dois padrões principais no mercado.

---

## Padrão 1: Monorepo por Ambiente (este repositório)

Ideal para times pequenos e projetos únicos. Separa os ambientes por diretório:

```
terraform/
├── modules/               # módulos reutilizáveis (sem estado)
│   ├── vpc/
│   ├── ec2/
│   ├── alb/
│   └── rds/
├── environments/
│   ├── dev/               # cada ambiente tem seu próprio estado
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── backend.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   │   └── ...
│   └── prod/
│       └── ...
└── bootstrap/             # cria o backend de estado (roda uma única vez)
    ├── main.tf
    └── outputs.tf
```

**Vantagens:**
- Simples de entender e navegar
- Um `terraform apply` por ambiente
- Isolamento completo de estado

---

## Padrão 2: Monorepo por Componente (Terragrunt)

Ideal para projetos grandes com muitos componentes independentes:

```
terraform/
├── modules/                # módulos reutilizáveis
│   ├── vpc/
│   └── ...
├── live/                   # infraestrutura "viva" por ambiente
│   ├── dev/
│   │   ├── networking/
│   │   │   └── terragrunt.hcl
│   │   ├── compute/
│   │   │   └── terragrunt.hcl
│   │   └── database/
│   │       └── terragrunt.hcl
│   └── prod/
│       └── ...
└── terragrunt.hcl          # configuração global (backend, versões)
```

Com Terragrunt, cada componente tem seu próprio estado e pode ser aplicado independentemente. Isso reduz o blast radius — uma mudança em `compute` não toca `database`.

---

## Arquivos Padrão por Diretório de Ambiente

Todo diretório de ambiente (ex: `environments/prod/`) deve ter:

```
prod/
├── backend.tf        # configuração do backend remoto
├── main.tf           # chamadas de módulos
├── variables.tf      # declaração de variáveis
├── outputs.tf        # outputs do ambiente
├── providers.tf      # configuração do provider (região, perfil, etc.)
├── locals.tf         # valores locais do ambiente
└── terraform.tfvars  # valores das variáveis (NÃO commitar se houver segredos)
```

---

## Convenções de Nomenclatura

### Recursos
```hcl
# Padrão: <projeto>-<ambiente>-<componente>-<recurso>
resource "aws_vpc" "main" {
  tags = {
    Name = "meu-projeto-prod-vpc"
  }
}
```

### Variáveis
- `snake_case` sempre
- Descritivas: `vpc_cidr_block`, não `cidr`
- Booleanos começam com `enable_`, `is_`, `create_`: `enable_nat_gateway`

### Módulos
- Substantivos no singular: `vpc`, `ec2`, `database`
- Sem abreviações desnecessárias

---

## Versionamento de Módulos em Produção

Em produção, módulos locais devem ser referenciados por tag git — não por caminho relativo:

```hcl
# ❌ Em produção — depende de onde está o código
module "vpc" {
  source = "../../modules/vpc"
}

# ✅ Em produção — versão fixada, reproduzível
module "vpc" {
  source = "git::https://github.com/sua-empresa/terraform-modules.git//vpc?ref=v1.2.0"
}
```

---

## Fluxo de Pull Request para Infraestrutura

```
1. Branch: infra/add-rds-to-prod
2. terraform fmt + terraform validate
3. tflint + checkov
4. terraform plan -out=pr-plan.tfplan
5. Revisão humana do plan no PR
6. Merge na main
7. terraform apply pr-plan.tfplan (via CI/CD ou manual)
8. git tag v1.3.0 (se versionar módulos)
```

---

## Resumo: O que Todo Repositório Profissional Tem

| Item | Por quê |
|---|---|
| `.gitignore` rigoroso | Protege secrets e state |
| `backend.tf` remoto (S3+DDB) | Trabalho em time |
| Módulos separados de environments | Reutilização |
| `terraform.tfvars.example` | Documenta variáveis necessárias |
| `checkov` ou `trivy` no CI | Segurança automatizada |
| `terraform fmt` no pre-commit | Consistência de formatação |
| README por módulo | Documentação de interface |
| Tags semânticas em módulos | Rastreabilidade |
