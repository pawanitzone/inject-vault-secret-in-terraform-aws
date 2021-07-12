# inject-vault-secret-in-terraform-aws
###Install Terraform
###Install Vault and start service: 
   vault server -dev -dev-listen-address="ip_address_of_server:8200" -dev-root-token-id="mysecrettoken" &
   
###Create AWS IAM user

###Set env variable:
- export TF_VAR_aws_access_key=XXXXXXXXXXX
- export TF_VAR_aws_secret_key=XXXXXXXXXXXXXXXX
- export VAULT_ADDR=http://ip_address_of_server:8200
- export VAULT_TOKEN=mysecrettoken

###clone this repo
 #cd vault_admin_workspace
 #terraform init
 #terraform apply
 #cd jenkins-instance
 #terraform init
 #terraform apply
