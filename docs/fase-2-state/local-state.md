# Estado Local

## O que é o `terraform.tfstate`?

Após o primeiro `terraform apply`, o Terraform cria um arquivo `terraform.tfstate` no diretório atual. Ele é um arquivo JSON que armazena o **mapeamento entre seu código e os recursos reais na nuvem**.

Abra o arquivo após criar recursos e você verá algo assim:

```json
{
  "version": 4,
  "terraform_version": "1.9.0",
  "serial": 3,
  "lineage": "a6e4a2c9-...",
  "outputs": {
    "bucket_arn": {
      "value": "arn:aws:s3:::meu-bucket-123",
      "type": "string"
    }
  },
  "resources": [
    {
      "mode": "managed",
      "type": "aws_s3_bucket",
      "name": "meu_bucket",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "id": "meu-bucket-123",
            "arn": "arn:aws:s3:::meu-bucket-123",
            "bucket": "meu-bucket-123",
            "region": "us-east-1",
            "tags": {
              "Environment": "dev",
              "ManagedBy": "terraform"
            }
          }
        }
      ]
    }
  ]
}
```

---

## Regras de Ouro sobre o State

!!! danger "NUNCA faça isso"
    1. **Nunca edite o `.tfstate` manualmente** — use os comandos `terraform state` para manipulações
    2. **Nunca commite o `.tfstate` no git** — ele contém dados sensíveis (IPs, IDs, às vezes senhas)
    3. **Nunca delete o `.tfstate` sem destruir os recursos primeiro** — o Terraform perde o rastreamento e não consegue mais gerenciar esses recursos

---

## Comandos de Inspeção

### `terraform state list`
Lista todos os recursos rastreados pelo estado:

```bash
terraform state list

# aws_s3_bucket.meu_bucket
# aws_s3_bucket_versioning.versioning
```

### `terraform state show`
Mostra todos os atributos de um recurso específico:

```bash
terraform state show aws_s3_bucket.meu_bucket

# # aws_s3_bucket.meu_bucket:
# resource "aws_s3_bucket" "meu_bucket" {
#     arn    = "arn:aws:s3:::meu-bucket-123"
#     bucket = "meu-bucket-123"
#     id     = "meu-bucket-123"
#     region = "us-east-1"
#     tags   = {
#         "Environment" = "dev"
#     }
# }
```

### `terraform show`
Mostra todo o estado atual de forma legível:

```bash
terraform show
```

---

## Comandos de Manipulação

Use esses comandos com cuidado — eles modificam o estado sem chamar a API da nuvem.

### `terraform state mv`
Move um recurso dentro do estado (útil ao renomear recursos no código):

```bash
# Renomear "meu_bucket" para "principal"
terraform state mv aws_s3_bucket.meu_bucket aws_s3_bucket.principal
```

Sem esse comando, ao renomear no código, o Terraform destruiria o bucket antigo e criaria um novo.

### `terraform state rm`
Remove um recurso do rastreamento do Terraform, sem destruí-lo na nuvem:

```bash
# Parar de gerenciar o bucket (o bucket continua existindo na AWS)
terraform state rm aws_s3_bucket.meu_bucket
```

Útil quando você quer "adotar" um recurso existente ou transferi-lo para outro projeto Terraform.

### `terraform import`
O inverso do `state rm` — traz um recurso existente para o gerenciamento do Terraform:

```bash
# Importar um bucket existente chamado "meu-bucket-legado"
terraform import aws_s3_bucket.legado meu-bucket-legado
```

---

## O Arquivo `.tfstate.backup`

A cada `terraform apply`, o Terraform cria automaticamente um backup do estado anterior em `terraform.tfstate.backup`. Se algo der errado, você pode restaurar manualmente. Mas lembre: esse arquivo também **não vai para o git**.

---

## Próximo

➡️ [Estado Remoto](remote-state.md) — como resolver os problemas do estado local com um backend S3 + DynamoDB.
