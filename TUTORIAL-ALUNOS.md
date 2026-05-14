# TUTORIAL COMPLETO — TERRAFORM NA AWS

**Projeto:** projeto-aula-5  
**Região:** us-east-1 (N. Virginia)

## PARTE 1 — O QUE É TERRAFORM?

Terraform é uma ferramenta de **Infraestrutura como Código (IaC)** criada pela HashiCorp. Em vez de clicar em menus no Console da AWS, você **escreve** em arquivos de texto (`.tf`) exatamente quais recursos deseja criar, e o Terraform se encarrega de criar, modificar ou destruir esses recursos de forma automática e reproduzível.

### Por que isso importa?

#### Antes do IaC
- Um engenheiro clicava manualmente no Console AWS
- Ninguém sabia exatamente o que havia sido criado
- Recriar o ambiente em outro lugar levava dias
- Erros humanos eram frequentes

#### Com o Terraform
- A infraestrutura vira código versionado no Git
- Qualquer pessoa pode ver exatamente o que existe
- Recriar o ambiente inteiro demora minutos
- O Terraform impede configurações inconsistentes

### Como o Terraform pensa?

O Terraform trabalha com três etapas fundamentais:

1. `WRITE` → Você escreve os arquivos `.tf` descrevendo o que quer
2. `PLAN` → O Terraform calcula o que precisa criar/modificar/destruir
3. `APPLY` → O Terraform executa as mudanças na nuvem

Ele também mantém um arquivo chamado `terraform.tfstate` que registra tudo que já foi criado. Esse arquivo é a “memória” do Terraform, então **nunca o apague**.

### Conceitos essenciais

- **PROVIDER:** plugin que conecta o Terraform a um serviço (ex.: AWS, Azure)
- **RESOURCE:** um recurso real na nuvem (ex.: EC2, bucket S3)
- **MODULE:** grupo de recursos reutilizáveis empacotados juntos
- **VARIABLE:** parâmetro que você passa para personalizar um módulo
- **OUTPUT:** valor que um módulo retorna (ex.: IP da EC2 criada)
- **STATE:** arquivo que registra o que o Terraform já criou
- **PLAN:** prévia de tudo que vai ser criado/alterado/destruído
- **APPLY:** execução real das mudanças

## IMPORTANTE — ADAPTAÇÕES PARA O AWS ACADEMY (LEARNER LAB)

O AWS Academy usa uma role de laboratório chamada `voclabs` que **bloqueia** certas operações IAM por segurança. Por isso, alguns recursos foram adaptados ou desabilitados neste projeto para funcionar nesse ambiente.

| Recurso | Status no Academy | Motivo do bloqueio |
|---|---|---|
| VPC Flow Logs | Desabilitado | `iam:CreateRole` bloqueado |
| AWS Config (recorder) | Desabilitado | `iam:CreateRole` bloqueado |
| AWS Config (11 regras) | Desabilitado | Depende do recorder |
| CloudTrail + CloudWatch | Parcial (só S3) | `iam:CreateRole` bloqueado |
| Amazon Inspector v2 | Desabilitado | `inspector2:Enable` bloqueado |
| Módulo IAM (grupos) | Desabilitado | `iam:CreateGroup` bloqueado |

### O que funciona normalmente no Academy

- GuardDuty
- Security Hub (CIS + AWS Foundational + integração GuardDuty)
- CloudTrail com bucket S3
- Buckets S3 de log
- VPC completa
- EC2 + ALB + WAF

**Nota:** em uma conta AWS real (fora do Academy), esses recursos podem ser habilitados alterando os interruptores nos arquivos `.tf` (mudando `0` para `1` e removendo blocos comentados).

## PARTE 2 — O QUE ESSE TERRAFORM FAZ?

Este projeto cria uma infraestrutura AWS segura e organizada. Ele é dividido em 3 módulos ativos (o módulo IAM está desabilitado no Academy).

### MÓDULO 1 — VPC (Rede Privada Virtual)

Cria a fundação de rede do projeto com range `10.100.0.0/16` em 3 zonas de disponibilidade (AZ) na região `us-east-1`.

#### Subnets públicas (acesso direto à internet)
- `10.100.0.0/23` (AZ1)
- `10.100.10.0/23` (AZ2)
- `10.100.20.0/23` (AZ3)

#### Subnets de produção (privadas)
- `10.100.2.0/23` (AZ1)
- `10.100.12.0/23` (AZ2)
- `10.100.22.0/23` (AZ3)

#### Subnets de banco de dados (privadas)
- `10.100.4.0/23` (AZ1)
- `10.100.14.0/23` (AZ2)
- `10.100.24.0/23` (AZ3)

#### Subnets de desenvolvimento (privadas)
- `10.100.6.0/23` (AZ1)
- `10.100.16.0/23` (AZ2)
- `10.100.26.0/23` (AZ3)

#### Subnets de homologação (privadas)
- `10.100.8.0/23` (AZ1)
- `10.100.18.0/23` (AZ2)
- `10.100.28.0/23` (AZ3)

#### Outros recursos de rede criados
- Internet Gateway (IGW): porta de entrada/saída da internet
- NAT Gateway + EIP: permite que recursos privados acessem a internet sem serem acessíveis de fora
- Tabelas de rotas: definem por onde o tráfego de cada subnet caminha
- Network ACLs: firewall no nível de subnet (primeira linha de defesa)
- S3 VPC Endpoint: acesso ao S3 sem sair da rede AWS (gratuito, mais rápido e mais seguro)

`[DESABILITADO no Academy]` VPC Flow Logs requer `iam:CreateRole` (bloqueado pela role `voclabs`). Em conta real, habilite com `create_flow_logs = 1`.

### MÓDULO 2 — EC2 + ALB + WAF (Aplicação Web)

Cria a stack de aplicação web com proteção em camadas.

#### Security Groups
- SG do ALB: aceita HTTP (`80`) e HTTPS (`443`) de qualquer IP da internet
- SG da EC2: aceita tráfego **apenas** do SG do ALB (princípio do menor privilégio)

#### Application Load Balancer (ALB)
- Criado nas subnets públicas
- Listener na porta `80` (HTTP)
- Distribui tráfego para o Target Group

#### Target Group
- Registra a EC2 como destino do ALB
- Health check automático na rota `/`

#### EC2 Instance
- Tipo: `t3.micro` (2 vCPU, 1 GB RAM)
- AMI: Amazon Linux 2023 (buscada automaticamente)
- Localizada em subnet privada de produção
- IMDSv2 obrigatório
- Disco EBS `gp3` de 20 GB com criptografia em repouso

#### AWS WAF v2
- Associado ao ALB (intercepta antes de chegar na aplicação)
- Regras gerenciadas:
- `AWSManagedRulesCommonRuleSet` (OWASP Top 10)
- `AWSManagedRulesKnownBadInputsRuleSet`
- `AWSManagedRulesAmazonIpReputationList`
- `AWSManagedRulesLinuxRuleSet`

### MÓDULO 3 — SECURITY (Segurança e Compliance)

Habilita os principais serviços de segurança disponíveis no AWS Academy.

#### Amazon GuardDuty `[ATIVO]`
- Detecção de ameaças com Machine Learning
- Analisa logs de VPC Flow Logs, CloudTrail e DNS
- Datasources extras habilitados: logs S3, audit logs Kubernetes e proteção contra malware em EBS
- Gera findings quando detecta comportamento suspeito

#### Amazon Inspector v2 `[DESABILITADO no Academy]`
- Normalmente faz varredura automática de vulnerabilidades (CVEs)
- Bloqueado por `inspector2:Enable` na role `voclabs`
- Em conta real: habilitar em `modules/security/inspector.tf`

#### AWS Security Hub `[ATIVO]`
- Painel centralizado de segurança
- Padrões habilitados:
- CIS AWS Foundations Benchmark v1.4.0
- AWS Foundational Security Best Practices
- Integração com GuardDuty habilitada

#### AWS CloudTrail `[ATIVO — apenas S3]`
- Registra atividade de API na conta AWS
- Trail multi-region
- Validação de integridade dos logs ativada
- Bucket S3 dedicado com:
- Criptografia AES256
- Versionamento
- Lifecycle: S3-IA após 90 dias, Glacier após 365 dias
- Bucket policy bloqueando acesso público
- `[DESABILITADO no Academy]` integração com CloudWatch Logs por exigir `iam:CreateRole`

#### AWS Config `[PARCIAL — apenas bucket S3]`
- Recorder, Delivery Channel e 11 regras gerenciadas desabilitadas (`iam:CreateRole` bloqueado)
- Bucket S3 de destino criado normalmente
- Em conta real: habilitar recorder + regras em `modules/security/config.tf`

### MÓDULO 4 — IAM (Gerenciamento de Identidade e Acesso)

`[DESABILITADO no Academy — iam:CreateGroup bloqueado pela role voclabs]`

O módulo IAM existe em `modules/iam/`, mas está comentado em `main.tf`. Em conta real, descomente o bloco `module iam` para criar:

- **AulaAdministrador**
  Política: `AdministratorAccess`  
  Descrição: acesso total à conta AWS.

- **AulasomenteLeitura**
  Política: `ReadOnlyAccess`  
  Descrição: visualização sem criar/modificar/deletar recursos.

- **AulaFinanceiro**
  Políticas: `AWSBillingReadOnlyAccess` + inline policy (`ce:*`)  
  Descrição: acesso ao billing e Cost Explorer.  
  Atenção: exige “IAM User and Role Access to Billing Information” ativado pelo root.

- **AulaEC2devs**
  Política: `AmazonEC2FullAccess`  
  Descrição: controle total de EC2.

## PARTE 3 — TUTORIAL DE EXECUÇÃO

### Pré-requisitos

1. Terraform instalado (`>= 1.3`)  
   Download: https://developer.hashicorp.com/terraform/downloads  
   Verificar:
   ```bash
   terraform -version
   ```

2. AWS CLI instalado e configurado  
   Download: https://aws.amazon.com/cli/

   No AWS Academy (Learner Lab):
- Clique em **AWS Details**
- Clique em **Show** ao lado de AWS CLI
- Copie as credenciais (Access Key, Secret Key, Session Token)
- Cole em `C:\Users\<seu-usuario>\.aws\credentials` (ou execute `aws configure`)
- `Default region name`: `us-east-1`
- `Default output format`: `json`

   As credenciais do Academy expiram ao encerrar o laboratório. Renove antes de novo `apply`.

3. Verificar autenticação:
   ```bash
   aws sts get-caller-identity
   ```

### Estrutura de arquivos do projeto

```text
Terraform/
├── main.tf                       # ponto de entrada
├── data.tf                       # informações da conta AWS
├── outputs.tf                    # saídas pós-apply
├── topologia-projeto-aula-5.png  # diagrama da arquitetura
└── modules/
    ├── vpc/                      # VPC, subnets, etc.
    ├── ec2_alb/                  # EC2 + ALB + WAF
    ├── security/                 # GuardDuty, Security Hub, CloudTrail...
    └── iam/                      # grupos IAM (desabilitado no Academy)
```

### Passo a passo de execução

Abra o terminal e navegue até a pasta do projeto:

```bash
cd "C:\caminho\para\Terraform"
```

#### Passo 1: `terraform init`

Baixa providers e registra módulos.

```bash
terraform init
```

Saída esperada (resumo):

```text
Initializing modules...
Initializing provider plugins...
Terraform has been successfully initialized!
```

#### Passo 2: `terraform validate`

Valida a sintaxe sem chamar a AWS.

```bash
terraform validate
```

Saída esperada:

```text
Success! The configuration is valid.
```

#### Passo 3: `terraform plan`

Mostra tudo que será criado/modificado/destruído.

```bash
terraform plan
```

Legenda:
- `+` será criado
- `~` será modificado
- `-` será destruído

Exemplo de resumo:

```text
Plan: 85 to add, 0 to change, 0 to destroy.
```

Para salvar o plano:

```bash
terraform plan -out=plano.tfplan
```

#### Passo 4: `terraform apply`

Aplica as mudanças na AWS.

```bash
terraform apply
```

Ou usando o plano salvo:

```bash
terraform apply plano.tfplan
```

Confirmação:

```text
Do you want to perform these actions? Enter a value: yes
```

**Atenção a custos em conta AWS real:**
- NAT Gateway
- ALB
- EC2 `t3.micro`
- Buckets S3
- GuardDuty / Security Hub

No AWS Academy, os créditos do laboratório cobrem durante a sessão. Ao final, execute `terraform destroy`.

Após o apply, exemplos de outputs:

```text
alb_dns_name          = "projeto-aula-5-ALB-xxxx.us-east-1.elb.amazonaws.com"
cloudtrail_s3_bucket  = "projeto-aula-5-cloudtrail-123456789"
config_s3_bucket      = "projeto-aula-5-aws-config-123456789"
ec2_instance_id       = "i-0123456789abcdef0"
ec2_private_ip        = "10.100.2.x"
guardduty_detector_id = "abc123..."
vpc_id                = "vpc-0123456789abcdef0"
waf_web_acl_arn       = "arn:aws:wafv2:..."
```

#### Passo 5: verificar o resultado

Acesse a aplicação pelo DNS do ALB:

```text
http://<valor do alb_dns_name>
```

Verifique no Console AWS (região `us-east-1`):
- VPC > Your VPCs > `projeto-aula-5-VPC`
- EC2 > Instances > `projeto-aula-5-EC2`
- EC2 > Load Balancers > `projeto-aula-5-ALB`
- WAF > Web ACLs > `projeto-aula-5-WAF`
- GuardDuty > detector `ENABLED`
- Security Hub > padrões CIS + AWS Foundational
- CloudTrail > trail `projeto-aula-5-Trail` com `LOGGING`
- S3 > buckets de log (cloudtrail e config)

Não disponíveis no Academy:
- AWS Config Dashboard (recorder desabilitado)
- IAM Groups (módulo desabilitado)

### Comandos úteis do dia a dia

```bash
terraform show
terraform state list
terraform state show module.vpc.aws_vpc.main
terraform output
terraform apply -replace=module.ec2_alb.aws_instance.main
terraform plan
terraform fmt -recursive
```

### Como destruir tudo (cuidado)

```bash
terraform destroy
```

Confirme com `yes`.

Atenção: comando irreversível. Se buckets S3 estiverem com `force_destroy = false`, esvazie antes:

```bash
aws s3 rm s3://<nome-do-bucket> --recursive
```

### Problemas comuns e soluções

- **Erro:** `No valid credential sources found`  
  **Solução:** renove credenciais do Academy.

- **Erro:** `Error: Bucket already exists`  
  **Causa:** nome de bucket S3 é global.  
  **Solução:** usar `terraform import` ou ajustar nome do bucket.

- **Erro:** `AccessDenied` com `iam:CreateRole`/`iam:CreateGroup`  
  **Causa:** restrições da role `voclabs`.  
  **Solução:** verificar se recursos bloqueados foram reativados.

- **Erro:** `GuardDuty detector already exists`  
  **Solução:**
  ```bash
  terraform import module.security.aws_guardduty_detector.main <detector-id>
  ```

- **Erro:** `Security Hub já está habilitado`  
  **Solução:** desabilitar manualmente no Console ou importar:
  ```bash
  terraform import module.security.aws_securityhub_account.main <account-id>
  ```

- **Erro:** `terraform init` falha por falta de internet  
  **Solução:** revisar conexão (o provider AWS precisa ser baixado).

- **Erro:** `The terraform.tfstate file is missing`  
  **Atenção:** sem state o Terraform perde referência do que criou.  
  **Solução:** reimportar recursos com `terraform import` ou remover manualmente no Console.

### Boas práticas aprendidas neste projeto

1. Use módulos para organização e reuso
2. Nunca commite credenciais
3. Use variáveis em vez de hardcode
4. Sempre revise o `plan`
5. Em equipe, use backend remoto para state (S3 + DynamoDB)
6. Use tags em todos os recursos
7. Aplique menor privilégio
8. Use criptografia (EBS/S3/IMDSv2)
9. Garanta auditoria (CloudTrail + GuardDuty)
10. Use defesa em profundidade (WAF + SG + NACL + Security Hub)
11. Adapte o código às limitações do ambiente

---

**Bons estudos!**
