# 02. Gestão de Estado

O estado (`terraform.tfstate`) é o coração do Terraform. Entendê-lo é o que separa quem usa Terraform de quem realmente sabe trabalhar com Terraform.

---

## O que você vai aprender

- O que é o arquivo de estado e o que ele contém
- Por que o estado é crítico e o que acontece se ele for perdido ou corrompido
- A diferença entre estado local e remoto
- Como configurar um backend S3 com DynamoDB para locking
- Comandos para inspecionar e manipular o estado com segurança

---

## Por que o Estado Existe?

O Terraform precisa saber qual infraestrutura ele criou anteriormente para calcular o que precisa mudar. Sem o estado, cada `terraform apply` tentaria criar tudo do zero.

O arquivo `terraform.tfstate` mapeia cada bloco `resource` do seu código ao recurso real na nuvem:

```json
{
  "resources": [
    {
      "type": "aws_s3_bucket",
      "name": "meu_bucket",
      "instances": [
        {
          "attributes": {
            "id": "meu-bucket-123",
            "arn": "arn:aws:s3:::meu-bucket-123",
            "bucket": "meu-bucket-123"
          }
        }
      ]
    }
  ]
}
```

---

## O Problema do Estado Local

Por padrão, o estado fica em `terraform.tfstate` no seu diretório local. Isso funciona para estudos, mas em um time real cria problemas sérios:

| Problema | Impacto |
|---|---|
| Arquivo no computador de uma pessoa | Outros do time não conseguem aplicar mudanças |
| Dois `apply` simultâneos | Corrupção do estado — infraestrutura inconsistente |
| Arquivo commitado no git | Dados sensíveis expostos (IPs, IDs, segredos) |
| Computador quebra | Estado perdido — Terraform não sabe mais o que criou |

**A solução: Estado Remoto.**

---

## Módulos desta Fase

1. **[Estado Local](local-state.md)** — anatomia do arquivo de estado e comandos de inspeção
2. **[Estado Remoto](remote-state.md)** — backend S3 + DynamoDB locking na prática

---

## Exercício da Fase

Migrar o estado local do bucket criado na Fase 1 para um backend S3 no LocalStack, com DynamoDB para state locking. Ao final, o `terraform.tfstate` local não deve mais existir.

---

## Próxima Fase

➡️ [Fase 3 — Variáveis, Outputs e Locals](../fase-3-variaveis/index.md)
