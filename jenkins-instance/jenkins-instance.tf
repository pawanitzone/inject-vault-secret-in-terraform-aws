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

resource "aws_key_pair" "jenkins-key" {
  public_key = "${var.ec2-public-key.public_key}"
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_security_group" "jenkins-sg" {
  vpc_id = "${aws_default_vpc.default.id}"
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "jenkins-sg"
  }
}

resource "aws_instance" "jenkins_server" {
  ami = "${var.jenkins-ami.ap-south-1}"
  instance_type = "${var.jenkins_instance_type}"
  key_name = aws_key_pair.jenkins-key.id
  associate_public_ip_address = true
  #security_groups = [aws_default_security_group.jenkins-sg.id]
  vpc_security_group_ids = [aws_default_security_group.jenkins-sg.id]
  tags = {
    Name = var.name

  }
provisioner "file" {
    source = "script.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "sudo /tmp/script.sh"
    ]
  }

  connection {
    type = "ssh"
    host = self.public_ip
    user = "${var.ubuntu-instance-username}"
    private_key = "${file("${var.ubunut-ec2-private-key}")}"
  }

}