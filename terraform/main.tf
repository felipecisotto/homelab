terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      #latest version as of Nov 30 2022
      version = "3.0.1-rc9"
    }
  }
}

provider "proxmox" {
  # References our vars.tf file to plug in the api_url 
  pm_api_url = var.api_url
  # References our secrets.tfvars file to plug in our token_id
  pm_api_token_id = var.token_id
  # References our secrets.tfvars to plug in our token_secret 
  pm_api_token_secret = var.token_secret
  # Default to `true` unless you have TLS working within your pve setup 
  pm_tls_insecure = false
}

resource "proxmox_vm_qemu" "my-vm" {
  name        = "media-server"
  target_node = "proxmox"
  clone       = "ubuntu-template"
  full_clone  = true
  memory      = 8192
  scsihw      = "virtio-scsi-pci"
  onboot      = true
  disks {
    ide {
      ide2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          storage    = "local-lvm"
          size       = "100G"
          emulatessd = true
        }
      }
      scsi1 {
        passthrough {
          file = "media:vm-108-disk-0"
        }
      }
    }
  }
  ciuser     = "ubuntu"
  cipassword = "felipe"
  ipconfig0  = "ip=192.168.0.206/24,gw=192.168.0.254"
  sshkeys    = var.ssh_key
  cpu {
    cores   = 4
    sockets = 1
  }
  vga {
    type = "serial0"
  }
  pci {
    id         = 1
    mapping_id = "gpu"
    pcie       = true
    # primary_gpu = true
  }
  machine = "q35"
  network {
    id     = 0
    bridge = "vmbr0"
    model  = "virtio"
  }
  serial {
    id = 0
  }
}

resource "proxmox_lxc" "github-runner" {
  hostname    = "github-runner"
  target_node = "proxmox"
  ostemplate  = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  rootfs {
    storage = "local-lvm"
    size    = "10G"
  }
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "192.168.0.207/24"
    gw     = "192.168.0.254"
  }
  password = "felipe"
  ssh_public_keys = var.ssh_key
}

resource "proxmox_lxc" "caddy" {
  hostname    = "caddy"
  target_node = "proxmox"
  ostemplate  = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  rootfs {
    storage = "local-lvm"
    size    = "5G"
  }
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "192.168.0.212/24"
    gw     = "192.168.0.254"
  }
  password = "felipe"
  ssh_public_keys = var.ssh_key
}

resource "proxmox_lxc" "kafka" {
  hostname    = "kafka"
  target_node = "proxmox"
  ostemplate  = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  memory      = 2048
  unprivileged  = false
  rootfs {
    storage = "local-lvm"
    size    = "10G"
  }
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "192.168.0.213/24"
    gw     = "192.168.0.254"
  }
  password = "felipe"
  ssh_public_keys = var.ssh_key
}

resource "proxmox_lxc" "cf_tunnel" {
  hostname    = "cf-tunnel"
  target_node = "proxmox"
  ostemplate  = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  onboot      = true
  rootfs {
    storage = "local-lvm"
    size    = "5G"
  }
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "192.168.0.214/24"
    gw     = "192.168.0.254"
  }
  password = "felipe"
  ssh_public_keys = var.ssh_key

}