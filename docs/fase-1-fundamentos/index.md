# 01. Fundamentos HCL e Ciclo de Vida

Esta é a fase mais importante. Tudo que vem depois é construído sobre esses conceitos. Não avance sem ter clareza total aqui.

---

## O que você vai aprender

- A sintaxe da linguagem HCL (HashiCorp Configuration Language)
- O que é um Provider e como o AWS Provider funciona
- O ciclo completo de vida: `init` → `plan` → `apply` → `destroy`
- Como o Terraform sabe o que criar, modificar ou destruir

---

## Por que o Terraform existe?

Imagine que você precisa criar uma VPC, 3 subnets, 2 instâncias EC2, um load balancer e um banco de dados RDS na AWS. Você poderia fazer isso pelo Console web, mas:

- É repetitivo e propenso a erros
- Não tem histórico de alterações
- É impossível replicar em outro ambiente sem refazer tudo
- Se alguém mudar algo pelo Console, você não fica sabendo

O Terraform resolve esses problemas: você **descreve** o estado desejado da infraestrutura em código, e ele se encarrega de criar, atualizar ou destruir recursos para chegar nesse estado.

!!! info "Infrastructure as Code (IaC)"
    IaC é o princípio de gerenciar infraestrutura usando código versionado, assim como você gerencia o código da aplicação. O Terraform é a ferramenta de IaC mais usada no mercado.

---

## Módulos desta Fase

1. **[Sintaxe HCL](hcl-syntax.md)** — A linguagem em si: blocos, argumentos, expressões e tipos de dados
2. **[Providers](providers.md)** — O que são providers e como configurar o AWS Provider
3. **[Ciclo de Vida](lifecycle.md)** — `init`, `plan`, `apply`, `destroy` na prática

---

## Exercício da Fase

Ao final desta fase, você vai criar um **S3 bucket no LocalStack** escrevendo cada linha do zero. Pequeno, mas completo: você vai passar por todo o ciclo de vida pela primeira vez.

---

## Próxima Fase

➡️ [Fase 2 — Gestão de Estado](../fase-2-state/index.md)
