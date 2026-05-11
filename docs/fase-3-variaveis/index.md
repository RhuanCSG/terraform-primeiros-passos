# 03. Variáveis, Outputs e Locals

Até aqui você escreveu código com valores hardcoded. Esta fase ensina a tornar o código parametrizável, reutilizável e sem repetição.

---

## O que você vai aprender

- Como parametrizar seu código com `variable` para aceitar diferentes valores por ambiente
- Como expor resultados do Terraform com `output`
- Como eliminar repetição com `locals`
- As funções built-in mais úteis do dia a dia

---

## O Problema que Essa Fase Resolve

Imagine que você tem um bucket configurado assim:

```hcl
resource "aws_s3_bucket" "app" {
  bucket = "minha-empresa-dev-app-storage"

  tags = {
    Environment = "dev"
    Project     = "minha-empresa"
    ManagedBy   = "terraform"
  }
}
```

Para criar o mesmo bucket no ambiente de produção, você duplicaria o arquivo inteiro e trocaria "dev" por "prod" — isso é um anti-pattern. Variáveis e locals resolvem isso.

---

## Módulos desta Fase

1. **[Variables](variables.md)** — tipos, validações, defaults e como passar valores
2. **[Outputs](outputs.md)** — expor informações após o apply
3. **[Locals](locals.md)** — calcular e reutilizar valores internamente

---

## Exercício da Fase

Refatorar o código da Fase 1 para usar variáveis (`bucket_name`, `environment`, `region`) e outputs (`bucket_arn`, `bucket_name`). O resultado final no LocalStack deve ser idêntico, mas o código será reutilizável em qualquer ambiente.

**Critério de conclusão:** `tflocal plan` retorna "No changes" após a refatoração.

---

## Próxima Fase

➡️ [Fase 4 — Módulos](../fase-4-modulos/index.md)
