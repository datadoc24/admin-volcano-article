terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}
#create a Personal Access Token in your Digital Ocean account with all permissions
variable "do_token" {default="dop_v1_xxxxxxx"}

provider "digitalocean" {
  token = var.do_token
}
