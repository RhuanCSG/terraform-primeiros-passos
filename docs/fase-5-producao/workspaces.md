# Workspaces

Workspaces permitem que um único conjunto de arquivos `.tf` gerencie múltiplos ambientes isolados, cada um com seu próprio estado.

---

## O Problema que Workspaces Resolvem

Você quer ter infraestrutura de `dev` e `prod` usando o mesmo código. Sem workspaces, você precisaria de diretórios separados ou gerenciar estados manualmente.

---

## Como Funcionam

```bash
# Listar workspaces (começa com apenas "default")
terraform workspace list

# Criar e mudar para workspace "dev"
terraform workspace new dev

# Criar e mudar para workspace "prod"
terraform workspace new prod

# Ver workspace atual
terraform workspace show

# Mudar de workspace
terraform workspace select dev
```

Cada workspace tem seu próprio arquivo de estado no backend. No S3, por exemplo:

```
s3://meu-bucket-state/
├── env:/
│   ├── dev/
│   │   └── terraform.tfstate
│   └── prod/
│       └── terraform.tfstate
└── terraform.tfstate     ← workspace "default"
```

---

## Usando o Workspace no Código

```hcl
locals {
  env = terraform.workspace   # "dev", "prod", "default"

  instance_type = {
    dev  = "t3.micro"
    prod = "t3.large"
  }

  instance_count = {
    dev  = 1
    prod = 3
  }
}

resource "aws_instance" "app" {
  count         = local.instance_count[local.env]
  instance_type = local.instance_type[local.env]

  tags = {
    Environment = local.env
  }
}
```

---

## Limitações dos Workspaces

Workspaces são simples de usar, mas têm limitações:

| Limitação | Impacto |
|---|---|
| Mesmo backend para todos os workspaces | Se o backend cair, todos os ambientes ficam inacessíveis |
| Difícil restringir quem pode aplicar em qual workspace | Sem RBAC nativo |
| Estado "invisível" para novos desenvolvedores | Requer documentação de qual workspace usar |
| Não isolam providers ou contas AWS | Dev e prod podem compartilhar a mesma conta |

Para projetos grandes em que isolamento completo importa (contas AWS separadas, backends separados), prefira **diretórios separados por ambiente** ao invés de workspaces.

---

## Workspaces vs. Diretórios

| | Workspaces | Diretórios separados |
|---|---|---|
| Isolamento de estado | Parcial (mesmo backend) | Total (backends independentes) |
| Isolamento de conta AWS | ❌ | ✅ (provider por diretório) |
| Simplicidade | Alta | Baixa (mais repetição) |
| Escalabilidade para times grandes | Limitada | Alta |
| Quando usar | Projetos pequenos/médios | Produção crítica, múltiplas contas |

---

## Próximo

➡️ [Segurança](security.md)
