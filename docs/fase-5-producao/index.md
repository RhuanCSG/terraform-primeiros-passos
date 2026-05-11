# 05. Produção e Boas Práticas

Esta é a fase de coroamento. Você vai aplicar tudo que aprendeu em uma infraestrutura real na AWS, seguindo os padrões que equipes profissionais usam em produção.

---

## O que você vai aprender

- Como gerenciar múltiplos ambientes com workspaces e estrutura de pastas
- Ferramentas de qualidade e segurança para código Terraform
- Gestão segura de segredos e credenciais
- Como estruturar repositórios para times e projetos grandes

---

## Ambiente

**Esta fase usa sua conta AWS real.** Os recursos criados incorrem em custo. Siga as instruções de cleanup ao final de cada exercício.

---

## O Projeto Final

Ao longo desta fase, você vai construir a arquitetura completa da VPC que foi planejada desde o início:

```
Internet
    │
[Internet Gateway]
    │
[Public Subnet — AZ-a]    [Public Subnet — AZ-b]
    ├── [Bastion Host]         (alta disponibilidade)
    └── [ALB — cross-AZ]
              │
[Private Subnet — AZ-a]   [Private Subnet — AZ-b]
    └── [EC2 — ASG]           └── [EC2 — ASG]
              │
[DB Subnet — AZ-a]        [DB Subnet — AZ-b]
    └── [RDS Primary]         └── [RDS Standby]
```

---

## Módulos desta Fase

1. **[Workspaces](workspaces.md)** — gerenciar dev/staging/prod com isolamento de estado
2. **[Segurança](security.md)** — credenciais, IAM, segredos e auditoria
3. **[Estrutura Profissional](estrutura-pastas.md)** — como grandes times organizam repositórios Terraform

---

## Critério de Conclusão

- `terraform apply` no ambiente `prod` cria toda a infraestrutura sem erros
- `checkov` não reporta falhas críticas de segurança
- Os ambientes `dev` e `prod` usam exatamente os mesmos módulos, com configurações diferentes
- `terraform destroy` limpa tudo sem deixar recursos órfãos

---

## Próximos Passos após Esta Fase

Veja o [Roadmap](../roadmap.md) para as trilhas avançadas: Terraform Cloud, Atlantis, CI/CD pipelines e Terragrunt.
