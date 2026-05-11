# Segurança em Terraform

Segurança em IaC não é opcional — é o que separa um projeto de brinquedo de infraestrutura pronta para produção.

---

## Regras Fundamentais

### 1. Nunca Commite Credenciais

```hcl
# ❌ CRÍTICO — NUNCA faça isso
provider "aws" {
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}
```

**Alternativas seguras:**

=== "Variável de ambiente (recomendado para CI/CD)"
    === "Linux / macOS"
        ```bash
        export AWS_ACCESS_KEY_ID="..."
        export AWS_SECRET_ACCESS_KEY="..."
        export AWS_DEFAULT_REGION="us-east-1"
        terraform apply
        ```

    === "PowerShell"
        ```powershell
        $env:AWS_ACCESS_KEY_ID = "..."
        $env:AWS_SECRET_ACCESS_KEY = "..."
        $env:AWS_DEFAULT_REGION = "us-east-1"
        terraform apply
        ```

=== "Perfil AWS CLI (recomendado para desenvolvimento local)"
    ```hcl
    provider "aws" {
      region  = "us-east-1"
      profile = "meu-perfil"  # ~/.aws/credentials
    }
    ```

=== "IAM Role (recomendado para EC2/Lambda/CI)"
    ```hcl
    # Sem credenciais — usa a role associada à instância/função
    provider "aws" {
      region = "us-east-1"
    }
    ```

---

### 2. Princípio do Least Privilege no IAM

A conta IAM usada pelo Terraform deve ter apenas as permissões necessárias para o que ele precisa criar. Nunca use `AdministratorAccess` em produção.

**Exemplo de policy mínima para criar VPC:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateVpc",
        "ec2:DescribeVpcs",
        "ec2:DeleteVpc",
        "ec2:CreateSubnet",
        "ec2:DescribeSubnets",
        "ec2:DeleteSubnet"
      ],
      "Resource": "*"
    }
  ]
}
```

---

### 3. Proteja o Arquivo de Estado

O `terraform.tfstate` pode conter dados sensíveis — IPs privados, IDs de recursos, e às vezes até senhas (se passadas como variáveis).

**Configurações obrigatórias no bucket S3 de estado:**

```hcl
# Versioning para recuperação
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration { status = "Enabled" }
}

# Criptografia em repouso
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"  # use KMS para controle de acesso granular
    }
  }
}

# Bloquear acesso público — NUNCA deixar o estado público
resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

---

### 4. Gestão de Segredos

**Nunca passe senhas diretamente como variável Terraform** — elas ficam no estado em texto claro.

**Alternativa: AWS Secrets Manager**

```hcl
# Armazenar a senha no Secrets Manager (fora do Terraform, ou via CLI)
# aws secretsmanager create-secret --name prod/db/password --secret-string "minhasenha"

# No Terraform, buscar o valor do Secrets Manager
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/db/password"
}

resource "aws_db_instance" "main" {
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
  # ...
}
```

**Alternativa: AWS SSM Parameter Store (mais simples e barato)**

```hcl
data "aws_ssm_parameter" "db_password" {
  name            = "/prod/db/password"
  with_decryption = true
}

resource "aws_db_instance" "main" {
  password = data.aws_ssm_parameter.db_password.value
}
```

---

## Ferramentas de Análise de Segurança

### `terraform validate`
Valida a sintaxe e configuração sem chamar APIs:
```bash
terraform validate
```

### `tflint`
Linter que detecta erros, deprecações e boas práticas:

=== "Linux / macOS"
    ```bash
    brew install tflint
    tflint --init
    tflint
    ```

=== "PowerShell"
    ```powershell
    winget install terraform-linters.tflint
    tflint --init
    tflint
    ```

### `checkov`
Análise estática de segurança — detecta configurações inseguras (buckets S3 públicos, security groups muito permissivos, etc.):

```bash
pip install checkov
checkov -d .

# Exemplo de output:
# Check: CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
# FAILED for resource: aws_s3_bucket.app
```

### `trivy`
Alternativa ao checkov, mais rápida:

=== "Linux / macOS"
    ```bash
    brew install aquasecurity/trivy/trivy
    trivy config .
    ```

=== "PowerShell"
    ```powershell
    winget install AquaSecurity.Trivy
    trivy config .
    ```

---

## Checklist de Segurança para Pull Requests

- [ ] Nenhuma credencial hardcodada no código
- [ ] Todos os security groups com regras específicas (sem `0.0.0.0/0` na entrada, exceto ALB porta 80/443)
- [ ] Buckets S3 com acesso público bloqueado
- [ ] RDS em subnet privada, sem `publicly_accessible = true`
- [ ] State backend com criptografia e versioning
- [ ] `checkov` sem falhas críticas
- [ ] IAM roles com least privilege

---

## Próximo

➡️ [Estrutura Profissional de Repositório](estrutura-pastas.md)
