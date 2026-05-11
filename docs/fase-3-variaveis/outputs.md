# Outputs (Saídas)

Outputs expõem valores de recursos criados pelo Terraform — para exibição no terminal, para uso em scripts externos, ou para compartilhamento entre módulos.

---

## Declaração

```hcl
# outputs.tf

output "bucket_arn" {
  value       = aws_s3_bucket.app.arn
  description = "ARN do bucket S3 criado"
}
```

Após o `terraform apply`, o valor é exibido:

```
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

bucket_arn = "arn:aws:s3:::minha-empresa-dev-storage"
```

---

## Campos de um Output

| Campo | Obrigatório | Descrição |
|---|---|---|
| `value` | **Sim** | O valor a ser exposto |
| `description` | Não | Documentação do output |
| `sensitive` | Não | Oculta o valor nos logs |
| `depends_on` | Não | Dependência explícita (raro) |

---

## Consultando Outputs

```bash
# Listar todos os outputs
terraform output

# Output específico
terraform output bucket_arn

# Em formato JSON (útil para scripts)
terraform output -json
```

---

## Outputs Sensíveis

```hcl
output "db_connection_string" {
  value     = "postgres://user:${aws_db_instance.main.password}@${aws_db_instance.main.endpoint}/app"
  sensitive = true
}
```

Para ver um output sensível:
```bash
terraform output -raw db_connection_string
```

---

## Outputs entre Módulos

O principal uso de outputs em projetos reais é **passar dados entre módulos**. O módulo filho expõe outputs, e o módulo raiz os consome:

```hcl
# modules/vpc/outputs.tf
output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
```

```hcl
# main.tf (módulo raiz)
module "vpc" {
  source = "./modules/vpc"
  cidr   = "10.0.0.0/16"
}

module "ec2" {
  source     = "./modules/ec2"
  vpc_id     = module.vpc.vpc_id                    # ← output do módulo vpc
  subnet_ids = module.vpc.private_subnet_ids         # ← output do módulo vpc
}
```

---

## Outputs de Coleções

```hcl
# Expor IDs de múltiplas instâncias
output "instance_ids" {
  value = aws_instance.app[*].id
  # Resultado: ["i-0abc123", "i-0def456", "i-0ghi789"]
}

# Expor um mapa de informações
output "instance_info" {
  value = {
    for idx, instance in aws_instance.app :
    "instance-${idx}" => {
      id         = instance.id
      private_ip = instance.private_ip
    }
  }
}
```

---

## Próximo

➡️ [Locals](locals.md)
