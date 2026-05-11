# Ciclo de Vida do Terraform

O Terraform funciona em quatro comandos principais que formam um ciclo. Entender o que cada um faz — e o que ele NÃO faz — é essencial para trabalhar com segurança.

---

## O Ciclo Completo

```
terraform init → terraform plan → terraform apply → terraform destroy
       ↑                ↑                ↑                  ↑
  Configuração     Visualizar       Executar           Remover
  e providers      mudanças         mudanças           tudo
```

---

## `terraform init`

**O que faz:** Inicializa o diretório de trabalho. Deve ser o primeiro comando executado em qualquer projeto, e sempre que você adicionar um novo provider ou módulo.

```bash
terraform init
```

O que acontece por baixo:
1. Lê o bloco `required_providers` e baixa os plugins de provider
2. Cria o diretório `.terraform/` com os binários dos providers
3. Gera (ou atualiza) o arquivo `.terraform.lock.hcl`
4. Configura o backend de estado (local ou remoto)

```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.31.0...
- Installed hashicorp/aws v5.31.0 (signed by HashiCorp)

Terraform has been successfully initialized!
```

!!! note "`.terraform/` não vai para o git"
    O diretório `.terraform/` contém binários baixados e está no `.gitignore`. Cada desenvolvedor roda `terraform init` localmente para baixar os providers.

---

## `terraform plan`

**O que faz:** Compara o estado atual da infraestrutura com o código e mostra **o que seria criado, modificado ou destruído** — sem executar nada.

```bash
terraform plan
```

Sempre leia o plan antes de aplicar. Ele mostra:

```
Terraform will perform the following actions:

  # aws_s3_bucket.meu_bucket will be created
  + resource "aws_s3_bucket" "meu_bucket" {
      + bucket = "meu-bucket-123"
      + id     = (known after apply)
      + arn    = (known after apply)
      ...
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

| Símbolo | Significado |
|---|---|
| `+` | Será criado |
| `~` | Será modificado |
| `-` | Será destruído |
| `-/+` | Será destruído e recriado (replacement) |

!!! warning "Cuidado com `-/+` (replacement)"
    Alguns argumentos são imutáveis — alterar o nome de um bucket S3, por exemplo, exige destruir o bucket antigo e criar um novo. Sempre analise replacements com atenção em produção.

**Salvando o plan:**
```bash
terraform plan -out=meuplan.tfplan
terraform apply meuplan.tfplan  # garante que só esse plan seja aplicado
```

---

## `terraform apply`

**O que faz:** Executa as mudanças descritas no plan, criando ou modificando recursos.

```bash
terraform apply
```

Sem um arquivo de plan salvo, o Terraform gera um novo plan e pede confirmação:

```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
```

Após a execução:
```
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

bucket_arn = "arn:aws:s3:::meu-bucket-123"
```

**Com auto-approve (use com cuidado):**
```bash
terraform apply -auto-approve
```

!!! tip "Em pipelines de CI/CD"
    Em automação, use `terraform apply -auto-approve` apenas após uma etapa de revisão do plan. Nunca aplique direto sem visualizar o plan primeiro.

---

## `terraform destroy`

**O que faz:** Remove **todos** os recursos gerenciados pelo Terraform naquele diretório.

```bash
terraform destroy
```

```
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes
```

!!! danger "Sem undo"
    `terraform destroy` em produção é irreversível. Recursos como buckets S3 com dados, bancos RDS e snapshots podem ser perdidos permanentemente. Sempre verifique o ambiente antes de destruir.

**Destruir apenas um recurso específico:**
```bash
terraform destroy -target=aws_s3_bucket.meu_bucket
```

---

## Outros Comandos Essenciais

```bash
# Valida a sintaxe dos arquivos .tf sem conectar à API
terraform validate

# Formata todos os arquivos .tf no diretório
terraform fmt

# Mostra o estado atual (o que o Terraform "vê" como existente)
terraform show

# Lista todos os recursos no estado
terraform state list

# Atualiza o estado com a realidade atual da infraestrutura
terraform refresh
```

---

## Fluxo Recomendado para o Dia a Dia

```
1. Editar o código (.tf)
2. terraform fmt          → formatar
3. terraform validate     → checar sintaxe
4. terraform plan         → revisar mudanças
5. (revisar o plan!)
6. terraform apply        → aplicar
7. git add + git commit   → commitar o código (nunca o .tfstate)
```

---

## Próximo

➡️ [Fase 2 — Gestão de Estado](../fase-2-state/index.md) — agora que você sabe criar recursos, vamos entender como o Terraform rastreia o que foi criado.
