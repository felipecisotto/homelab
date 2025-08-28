# 🏠 Homelab Infrastructure

Um projeto completo de infraestrutura homelab usando **Terraform** para provisionamento no Proxmox e **Ansible** para automação da configuração das VMs.

## 📋 Visão Geral

Este projeto provisiona e configura automaticamente uma infraestrutura homelab com os seguintes serviços:

- **Media Server**: VM Ubuntu com GPU passthrough para Plex/Jellyfin
- **GitHub Runner**: Container LXC para CI/CD automático
- **Caddy Server**: Proxy reverso e servidor web
- **Kafka**: Plataforma de streaming de dados com UI

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────┐
│                  Proxmox Host                   │
├─────────────────────────────────────────────────┤
│ media-server (VM)           │ 192.168.0.206     │
│ ├─ Ubuntu 22.04             │ 8GB RAM, 4 cores  │
│ ├─ Docker + NVIDIA          │ GPU Passthrough   │
│ └─ Media Services           │ 100GB Disk        │
├─────────────────────────────┼───────────────────┤
│ github-runner (LXC)         │ 192.168.0.207     │
│ ├─ Ubuntu 22.04             │ Actions Runner    │
│ └─ CI/CD Pipeline           │ 10GB Disk         │
├─────────────────────────────┼───────────────────┤
│ caddy (LXC)                 │ 192.168.0.212     │
│ ├─ Ubuntu 22.04             │ Reverse Proxy     │
│ └─ Web Server               │ 5GB Disk          │
├─────────────────────────────┼───────────────────┤
│ kafka (LXC)                 │ 192.168.0.213     │
│ ├─ Ubuntu 22.04             │ 2GB RAM           │
│ ├─ Kafka + Kafka UI        │ Privileged        │
│ └─ Streaming Platform       │ 10GB Disk         │
└─────────────────────────────────────────────────┘
```

## 🔧 Pré-requisitos

### Software Necessário

- **Terraform** >= 1.0
- **Ansible** >= 2.9
- **SSH Client** configurado
- **Proxmox VE** >= 7.0

### Proxmox Setup

1. **Template Ubuntu**: Criar template `ubuntu-template` no Proxmox
2. **API Token**: Configurar token de API no Proxmox
3. **GPU Passthrough**: Configurar passthrough da GPU (se necessário)
4. **Storage**: Configurar storage `local-lvm` e `media`

## ⚙️ Configuração Inicial

### 1. Clonar o Repositório

```bash
git clone <repository-url>
cd homelab
```

### 2. Configurar SSH Keys

```bash
# Gerar chave SSH se não existir
ssh-keygen -t rsa -b 4096 -f ~/.ssh/homelab

# Adicionar ao ssh-agent
ssh-add ~/.ssh/homelab
```

### 3. Configurar Variáveis do Terraform

Criar o arquivo `terraform/terraform.tfvars`:

```hcl
# Token de API do Proxmox
token_id = "usuario@pam!token_name"
token_secret = "token-secret-aqui"

# Chave SSH pública
ssh_key = "ssh-rsa AAAAB3NzaC1yc2E... sua-chave-publica"
```

### 4. Configurar Ansible Vault

```bash
# Criar arquivo de secrets criptografado
ansible-vault create ansible/group_vars/github-runner/vault.yml

# Adicionar o token do GitHub Runner:
vault_github_runner_token: "seu-github-token-aqui"
```

## 🚀 Deploy da Infraestrutura

### 1. Provisionar com Terraform

```bash
cd terraform

# Inicializar Terraform
terraform init

# Planejar deployment
terraform plan

# Aplicar configuração
terraform apply
```

### 2. Verificar VMs Criadas

```bash
# Listar recursos criados
terraform show

# Verificar conectividade
ping 192.168.0.206  # media-server
ping 192.168.0.207  # github-runner
ping 192.168.0.212  # caddy
ping 192.168.0.213  # kafka
```

## 🔧 Configuração com Ansible

### 1. Testar Conectividade

```bash
cd ansible

# Testar conexão com todos os hosts
ansible all -m ping

# Listar hosts do inventário
ansible-inventory --list
```

### 2. Deploy Completo

```bash
# Executar todos os playbooks
ansible-playbook main.yml --ask-vault-pass

# Ou executar serviços específicos:
ansible-playbook playbooks/docker/main.yml
ansible-playbook playbooks/nvidia/main.yml
ansible-playbook playbooks/specific/caddy.yml
ansible-playbook playbooks/specific/kafka/kafka.yml
ansible-playbook playbooks/specific/github-runner/main.yml
```

### 3. Verificar Serviços

```bash
# Verificar status dos serviços
ansible docker -m shell -a "docker --version"
ansible nvidia -m shell -a "nvidia-smi"
ansible kafka -m shell -a "systemctl status kafka"
```

## 🌐 Serviços Disponíveis

| Serviço | Host | Porta | URL | Descrição |
|---------|------|-------|-----|-----------|
| Media Server | 192.168.0.206 | 8096 | http://192.168.0.206:8096 | Jellyfin Media Server |
| Kafka UI | 192.168.0.213 | 8080 | http://192.168.0.213:8080 | Interface Kafka |
| Caddy | 192.168.0.212 | 80/443 | http://192.168.0.212 | Proxy Reverso |
| GitHub Runner | 192.168.0.207 | - | - | CI/CD Runner |

## 📁 Estrutura do Projeto

```
homelab/
├── terraform/              # Infraestrutura como código
│   ├── main.tf             # Recursos Proxmox
│   ├── vars.tf             # Variáveis
│   └── terraform.tfvars    # Valores das variáveis
├── ansible/                # Automação de configuração
│   ├── inventory.yml       # Inventário de hosts
│   ├── main.yml           # Playbook principal
│   ├── group_vars/        # Variáveis por grupo
│   │   ├── all/           # Variáveis globais
│   │   └── github-runner/ # Variáveis do runner
│   └── playbooks/         # Playbooks organizados
│       ├── all/           # Tarefas para todos os hosts
│       ├── docker/        # Instalação Docker
│       ├── nvidia/        # Drivers NVIDIA
│       └── specific/      # Configurações específicas
└── README.md              # Esta documentação
```

## 🔍 Troubleshooting

### Problemas Comuns

#### 1. Erro de Conexão SSH

```bash
# Verificar se a chave SSH está no ssh-agent
ssh-add -l

# Adicionar chave se necessário
ssh-add ~/.ssh/homelab

# Testar conexão direta
ssh -i ~/.ssh/homelab ubuntu@192.168.0.206
```

#### 2. Terraform Apply Falha

```bash
# Verificar estado atual
terraform show

# Forçar refresh do estado
terraform refresh

# Importar recursos existentes (se necessário)
terraform import proxmox_vm_qemu.my-vm proxmox/qemu/108
```

#### 3. Ansible Connection Failed

```bash
# Verificar inventário
ansible-inventory --list

# Testar conectividade específica
ansible media-server -m ping -vvv

# Verificar variáveis do host
ansible media-server -m setup
```

#### 4. Serviços Não Iniciando

```bash
# Verificar logs do serviço
ansible kafka -m shell -a "journalctl -u kafka -f"

# Reiniciar serviço
ansible kafka -m systemd -a "name=kafka state=restarted" --become
```

## 🔄 Comandos Úteis

### Terraform

```bash
# Destruir toda a infraestrutura
terraform destroy

# Aplicar apenas um recurso específico
terraform apply -target=proxmox_vm_qemu.my-vm

# Visualizar output formatado
terraform output
```

### Ansible

```bash
# Executar playbook específico
ansible-playbook playbooks/docker/main.yml --limit docker

# Verificar sintaxe do playbook
ansible-playbook main.yml --syntax-check

# Executar em modo dry-run
ansible-playbook main.yml --check

# Ver variáveis de um host
ansible-inventory --host media-server
```

## 📝 Próximos Passos

- [ ] Implementar backup automatizado
- [ ] Adicionar monitoramento com Prometheus
- [ ] Configurar SSL/TLS com Let's Encrypt
- [ ] Implementar log aggregation
- [ ] Adicionar alerting com Grafana

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.