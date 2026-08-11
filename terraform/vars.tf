#Blank var for use by terraform.tfvars
variable "token_secret" {
}
#Blank var for use by terraform.tfvars
variable "token_id" {
}
variable "api_url" {
  # default = "https://proxmox.felipecisotto.com.br/api2/json"
  default = "https://192.168.0.199:8006/api2/json"
}
variable "ssh_key" {
}
