# Módulo Terraform para criação VPC - Disciplina IAC Puc MG

Este repositório contém o módulo Terraform padrão para criação da nossa arquitetura de VPC na AWS. Ele é flexível e permite a criação condicional de diferentes camadas de rede.

## Pré-requisitos

- Terraform v1.2.0 ou superior
- Credenciais da AWS configuradas no ambiente

## Como Usar

1.  Clone este repositório:
    ```bash
    git clone [https://github.com/erickdavi/lab-terraform-aula-douglas.git](https://github.com/erickdavi/lab-terraform-aula-douglas.git)
    ```
2.  Navegue até a pasta do projeto:
    ```bash
    cd terraform-aws-vpc
    ```
3.  Edite o arquivo `main.tf` para configurar as variáveis desejadas. Principalmente os "interruptores" para cada ambiente.
4.  Execute o Terraform:
    ```bash
    terraform init
    terraform plan
    terraform apply
    ```

## Variáveis de Entrada (Interruptores)

As seguintes variáveis no bloco `module "vpc"` do `main.tf` controlam quais ambientes serão criados:

- `create_public_subnets`: (Padrão: 1) Cria a camada pública e o NAT Gateway.
- `create_production_subnets`: (Padrão: 1) Cria as sub-redes de Produção.
- `create_database_subnets`: (Padrão: 1) Cria as sub-redes de Banco de Dados.
- `create_dev_subnets`: (Padrão: 1) Cria as sub-redes de Desenvolvimento.
- `create_hml_subnets`: (Padrão: 1) Cria as sub-redes de Homologação.# lab-terraform-aula-douglas
