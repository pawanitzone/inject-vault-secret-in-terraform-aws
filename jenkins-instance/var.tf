
variable "jenkins-ami" {
  type = map
  default = {
    ap-south-1 = "ami-0c1a7f89451184c8b"
    eu-west-1 = "ami-0ee02acd56a52998e"
  }
}

variable "jenkins_instance_type" {
  type = string
  default = "t2.micro"
}



