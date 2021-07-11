variable "name" { default = "jenkins-instance" }
variable "region" { default = "ap-south-1" }
variable "path" { default = "../vault-admin-workspace/terraform.tfstate" }
variable "ttl" { default = "1" }

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

data "terraform_remote_state" "admin" {
  backend = "local"

  config = {
    path = var.path
  }
}

data "vault_aws_access_credentials" "creds" {
  backend = data.terraform_remote_state.admin.outputs.backend
  role    = data.terraform_remote_state.admin.outputs.role
}

provider "aws" {
  region = "${var.region}"
  access_key = "${data.vault_aws_access_credentials.creds.access_key}"
  secret_key = "${data.vault_aws_access_credentials.creds.secret_key}"
}

resource "aws_instance" "jenkins_server" {
  ami = "${var.jenkins-ami.ap-south-1}"
  instance_type = "${var.jenkins_instance_type}"
  tags = {
    Name = var.name

  }
}