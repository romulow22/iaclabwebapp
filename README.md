
## Pratica 03 - Infra estrutura para Web Application

## Participante

- Nome: Rômulo Alves de Souza Silva
- E-mail: 1545593@sga.pucminas.br
- Matricula: 212457

## estrutura do projeto

```bash
.
├── acme.tfvars
├── ansible
│   ├── ansible.cfg
│   ├── ansible_inventory.tpl
│   ├── ansible_inventory.yml
│   ├── group_vars
│   │   └── all.yml
│   ├── roles
│   │   ├── common
│   │   │   ├── tasks
│   │   │   │   └── main.yml
│   │   │   └── vars
│   │   │       └── main.yml
│   │   ├── datadog
│   │   │   ├── tasks
│   │   │   │   └── main.yml
│   │   │   ├── templates
│   │   │   │   └── datadog.conf.j2
│   │   │   └── vars
│   │   │       └── mail.yml
│   │   ├── db
│   │   │   ├── handlers
│   │   │   │   └── main.yml
│   │   │   ├── tasks
│   │   │   │   └── main.yml
│   │   │   └── vars
│   │   │       └── main.yml
│   │   └── web
│   │       ├── handlers
│   │       │   └── main.yml
│   │       ├── tasks
│   │       │   └── main.yml
│   │       ├── templates
│   │       │   └── index.html.j2
│   │       └── vars
│   │           └── main.yml
│   └── site.yml
├── apply.tfplan
├── destroy.tfplan
├── main.tf
├── outputs.tf
├── private_key.pem
├── providers.tf
├── public_key.pem
├── README.md
├── terraform.tfstate
├── terraform.tfstate.backup
├── variables.tf
└── vmmodule
    ├── main.tf
    ├── output.tf
    └── variables.tf

20 directories, 32 files
```



## Exemplo de roteiro

### Configurar variaveis

- Incluir suas chaves da azure em provider.tf
- Incluir sua chave da Datadog em /ansible/roles/datadog/vars/main.yml

### Provisionar infraestrutura

```bash
terraform init -upgrade
terraform plan -out apply.tfplan -var-file=acme.tfvars
terraform apply apply.tfplan
```

### Configurar serviços

```bash
cd ansible
ansible-playbook -i ansible_inventory.yml site.yml
```

### Destruir ambiente

```bash
cd ..
terraform plan -destroy -out destroy.tfplan -var-file=acme.tfvars
terraform apply destroy.tfplan
```

## Evidências

![Website](/images/website.png)

![Datadog](/images/datadog.png)



