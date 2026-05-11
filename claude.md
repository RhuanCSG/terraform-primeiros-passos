# Contexto do Projeto — Primeiros passos Terraform

## Objetivo

Guia de estudos para aprender Terraform do zero, com foco no que realmente importa para quem está começando. O projeto prático central é uma arquitetura VPC segura na AWS, construída incrementalmente ao longo das fases.

## Decisões de Arquitetura

### Provider e Ambiente
- **Cloud:** AWS
- **Fases 1–4:** LocalStack via Docker — simulador AWS local, sem custo e sem risco de recursos reais
- **Fase 5:** AWS real, conta do usuário, IAM com least privilege
- **Wrapper CLI:** `tflocal` — aponta os endpoints do Terraform automaticamente para o LocalStack

### Projeto Prático Central
Arquitetura VPC segura com três camadas de isolamento:
```
Internet → IGW → Subnets Públicas  → [Bastion Host] [ALB]
                                              ↓
                 Subnets Privadas  → [EC2 × N]
                                              ↓
                 Subnets de Banco  → [RDS Multi-AZ]
```

### Abordagem Pedagógica
- Progressão linear: cada fase entrega teoria em `docs/` + exercício prático em `src/`
- `src/` começa vazio e é construído ao vivo, fase a fase
- Cada exercício concluído gera um commit descritivo — o git history é o registro de evolução
- Comentários educacionais são permitidos nos arquivos `.tf` (exceção à regra padrão)

### Status do Projeto
Não há campo de status aqui. Ao iniciar uma sessão, descubra o estado atual lendo os arquivos presentes em `src/` e o histórico do git (`git log --oneline`).

## Stack e Versões

| Ferramenta | Versão mínima |
|---|---|
| Terraform | >= 1.9 |
| AWS Provider | ~> 5.0 |
| LocalStack | >= 3.x |
| tflocal | qualquer |
| Python | >= 3.10 |
| mkdocs-material | >= 9.x |

## Documentação (MkDocs)

- **Site publicado:** `https://rhuancsg.github.io/terraform-primeiros-passos/`
- **Theme:** Material for MkDocs, esquema de cores `indigo`, pt-BR
- **Navegação:** dois tabs — `Início` e `Roadmap`. Todas as fases ficam dentro de `Roadmap`
- **Formato de título das fases no nav:** `00. Título` (ex: `01. Fundamentos`)
- **Formato de título nas páginas:** `# 0N. Título` (ex: `# 01. Fundamentos HCL e Ciclo de Vida`)

## Convenções do Repositório

### Estrutura de Pastas
```
terraform/
├── docs/          # Teoria e documentação (MkDocs)
├── src/           # Código Terraform dos exercícios (vazio até a fase começar)
└── scripts/       # Utilitários de setup e limpeza (.sh e .ps1)
```

### Nomenclatura
- Pastas de fase: `fase-N-nome/` (ex: `fase-1-fundamentos/`)
- Módulos Terraform: substantivos no singular (`vpc/`, `ec2/`, `rds/`)
- Recursos: `snake_case` sempre
- Variáveis: `snake_case` descritivas (`vpc_cidr_block`, não `cidr`)

### Arquivos Padrão por Exercício em `src/`
- `main.tf` — recursos principais
- `variables.tf` — inputs
- `outputs.tf` — outputs
- `providers.tf` — configuração do provider (quando necessário separar)
- `terraform.tfvars.example` — exemplo commitável / `terraform.tfvars` — NÃO commitar

### Scripts
Cada script existe nas versões Linux/macOS (`.sh`) e PowerShell (`.ps1`):
- `scripts/setup.*` — verifica pré-requisitos do ambiente
- `scripts/cleanup.*` — destrói recursos e limpa estado local de um exercício

## Regras de Segurança

1. Nunca commitar `.tfstate`, `.tfvars` reais, credenciais ou `.env`
2. Nunca usar `access_key` ou `secret_key` hardcoded em arquivos `.tf`
3. Autenticação via variáveis de ambiente ou perfis AWS CLI
4. Segredos em produção: AWS Secrets Manager ou SSM Parameter Store
5. IAM: least privilege — roles específicas, nunca `AdministratorAccess` em produção

## Roadmap

| Fase | Tema | Ambiente |
|---|---|---|
| 00 | Setup (Terraform, LocalStack, AWS CLI) | Local |
| 01 | Fundamentos HCL e Ciclo de vida | LocalStack |
| 02 | Gestão de Estado (local → remoto) | LocalStack |
| 03 | Variáveis, Outputs, Locals | LocalStack |
| 04 | Módulos | LocalStack |
| 05 | Produção, Workspaces, Segurança | AWS Real |

Detalhamento completo em `docs/roadmap.md`.
