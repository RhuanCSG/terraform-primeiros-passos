# 04. Módulos

Módulos são a principal ferramenta de reutilização e organização em projetos Terraform de médio e grande porte. Dominar módulos é o que diferencia código amador de código profissional.

---

## O que você vai aprender

- O que é um módulo e por que ele existe
- Como criar um módulo local reutilizável
- Como consumir módulos — locais e do Terraform Registry
- Como passar dados para módulos e receber dados de volta
- Boas práticas de interface de módulo

---

## O Problema que Módulos Resolvem

Sem módulos, para criar dois ambientes (dev e prod) com a mesma configuração de VPC, você copiaria e colaria o código — duplicando centenas de linhas. Qualquer ajuste precisaria ser feito em dois lugares, e eles inevitavelmente ficam fora de sincronismo.

**Com módulos:**

```hcl
# dev/main.tf
module "vpc" {
  source = "../modules/vpc"
  cidr   = "10.0.0.0/16"
  env    = "dev"
}

# prod/main.tf
module "vpc" {
  source = "../modules/vpc"
  cidr   = "10.1.0.0/16"
  env    = "prod"
}
```

Uma única implementação, dois usos — cada um com configuração própria.

---

## Módulos desta Fase

1. **[Criando Módulos](criando-modulos.md)** — anatomia e boas práticas de interface
2. **[Terraform Registry](registry.md)** — usando módulos públicos validados pela comunidade

---

## Exercício da Fase

Extrair toda a configuração de VPC para um módulo `modules/vpc/` e criar dois "consumidores" do módulo — `dev/` e `prod/` — cada um com CIDRs diferentes. Todo o código de VPC deve existir apenas dentro do módulo.

---

## Próxima Fase

➡️ [Fase 5 — Produção](../fase-5-producao/index.md)
