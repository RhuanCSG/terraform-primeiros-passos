# Locals (Valores Locais)

Locals permitem calcular e nomear valores intermediários dentro de um módulo — como variáveis locais em uma função, mas para configurações de infraestrutura.

---

## Quando Usar Locals

Use `locals` quando:
- Você repete a mesma expressão em múltiplos lugares
- Uma expressão é complexa e merece um nome descritivo
- Quer calcular valores derivados de variáveis de input

---

## Declaração

```hcl
# locals.tf

locals {
  # Prefixo padronizado para todos os recursos do projeto
  name_prefix = "${var.project}-${var.environment}"

  # Tags aplicadas a todos os recursos
  common_tags = merge(var.extra_tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  })

  # Cálculo derivado
  is_production = var.environment == "prod"
}
```

**Uso:**

```hcl
resource "aws_s3_bucket" "app" {
  bucket = "${local.name_prefix}-storage"  # ← acessa com local.<nome>
  tags   = local.common_tags
}

resource "aws_instance" "app" {
  instance_type = local.is_production ? "t3.large" : "t3.micro"
  tags          = local.common_tags
}
```

---

## Locals vs Variables

| | `variable` | `locals` |
|---|---|---|
| Aceita valor externo | ✅ Sim | ❌ Não |
| Visível fora do módulo | ❌ Não (só via `output`) | ❌ Não |
| Pode usar funções | Limitado (em `default`) | ✅ Sim, livremente |
| Pode referenciar outros recursos | ❌ Não | ✅ Sim |
| Uso principal | Parametrizar código | Eliminar repetição |

---

## Locals com Funções

```hcl
locals {
  # Converter lista em set (remove duplicatas)
  unique_azs = toset(var.availability_zones)

  # Construir nomes padronizados de subnets
  public_subnet_names = [
    for idx in range(length(var.public_subnet_cidrs)) :
    "${local.name_prefix}-public-${idx + 1}"
  ]

  # Mapa de tags completo mesclando defaults com customizações
  resource_tags = merge(
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
      CreatedAt   = timestamp()
    },
    var.additional_tags
  )
}
```

---

## Funções Built-in Essenciais

O Terraform oferece dezenas de funções. Essas são as mais usadas no dia a dia:

### Strings
```hcl
format("%-10s", "hello")          # "hello     "
lower("HELLO")                     # "hello"
upper("hello")                     # "HELLO"
replace("hello world", " ", "-")  # "hello-world"
trimspace("  hello  ")             # "hello"
split(",", "a,b,c")                # ["a", "b", "c"]
join("-", ["a", "b", "c"])         # "a-b-c"
```

### Coleções
```hcl
length(["a", "b", "c"])            # 3
contains(["dev", "prod"], "dev")   # true
toset(["a", "b", "a"])             # {"a", "b"}
flatten([["a", "b"], ["c"]])       # ["a", "b", "c"]
merge({a = 1}, {b = 2})            # {a = 1, b = 2}
lookup({a = "x"}, "a", "default") # "x"
keys({a = 1, b = 2})              # ["a", "b"]
values({a = 1, b = 2})            # [1, 2]
```

### Condicionais e Verificações
```hcl
coalesce("", "fallback")           # "fallback" (primeiro não-null/empty)
try(var.optional_config.field, "") # retorna "" se a expressão falhar
can(var.config.field)              # true se a expressão for válida
```

### Numéricas
```hcl
max(1, 2, 3)                       # 3
min(1, 2, 3)                       # 1
ceil(1.2)                          # 2
floor(1.9)                         # 1
```

---

## Próximo

➡️ [Fase 4 — Módulos](../fase-4-modulos/index.md)
