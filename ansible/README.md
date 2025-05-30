# Ansible Homelab

Estrutura do projeto Ansible para gerenciamento do homelab.

## Estrutura de Diretórios

```
ansible/
├── group_vars/           # Variáveis específicas para grupos
│   ├── all/             # Variáveis para todos os hosts
│   ├── docker/          # Variáveis para hosts com Docker
│   └── nvidia/          # Variáveis para hosts com NVIDIA
├── host_vars/           # Variáveis específicas para hosts
│   └── media-server/    # Variáveis específicas para media-server
├── roles/               # Roles reutilizáveis
│   ├── common/          # Role para configurações comuns
│   ├── docker/          # Role para instalação do Docker
│   └── nvidia/          # Role para drivers NVIDIA
├── playbooks/           # Playbooks organizados por escopo
│   ├── all/            # Playbooks para todos os hosts
│   │   └── update.yml  # Atualização do sistema
│   ├── docker/         # Playbooks para hosts com Docker
│   ├── nvidia/         # Playbooks para hosts com NVIDIA
│   └── specific/       # Playbooks para hosts específicos
│       └── media-server/ # Configurações específicas do media-server
└── inventory.yml        # Inventário de hosts
```

## Organização

- **group_vars/**: Variáveis compartilhadas por grupos de hosts
- **host_vars/**: Variáveis específicas para cada host
- **roles/**: Roles reutilizáveis para diferentes funcionalidades
- **playbooks/**: Playbooks organizados por escopo
  - **all/**: Playbooks que se aplicam a todos os hosts
  - **docker/**: Playbooks específicos para hosts com Docker
  - **nvidia/**: Playbooks específicos para hosts com NVIDIA
  - **specific/**: Playbooks para configuração específica de hosts

## Uso

1. Para atualizar todos os hosts:
```bash
ansible-playbook playbooks/all/update.yml
```

2. Para configurar hosts com Docker:
```bash
ansible-playbook playbooks/docker/main.yml
```

3. Para configurar hosts com NVIDIA:
```bash
ansible-playbook playbooks/nvidia/main.yml
```

4. Para configurar um host específico:
```bash
ansible-playbook playbooks/specific/media-server/main.yml
``` 