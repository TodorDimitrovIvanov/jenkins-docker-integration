# How to setup 
## Terraform
This is the middleware that connects to AWS and deploys the EC2 instance. To run it, we simply have to execute the following commands:
```
terraform init
terraform plan
terraform apply 
```
## Ansible 
To setup Jenkins on the EC2 instance we first need to retrieve its IP Address or Hostname from the Terraform output and replace it in the following script
```
ansible-playbook -e "ec2_address=___IP____" example_playbook.yml
```