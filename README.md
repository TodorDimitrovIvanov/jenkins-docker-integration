# How to setup? 
## Quicksetup
Run the following command:
```
terraform apply -auto-approve; host_ip=$(tf output -raw ec2_instance_hostname); sed -i "s/EC2-PLACEHOLDER/$host_ip/g" ansible-inventory.yaml; ansible-playbook jenkins-setup.yaml -i ansible-inventory.yaml
```
## Terraform
This is the middleware that connects to AWS and deploys the EC2 instance. To run it, we simply have to execute the following commands:
```
terraform init
terraform plan
terraform apply 
```
## Ansible 
To setup Jenkins on the EC2 instance we first need to retrieve its IP Address or Hostname from the Terraform output and replace it in the ansible inventory
```
sed -i 's/EC2-PLACEHOLDER/_____IP_____/g'
```
And then start the process with: 
```
ansible-playbook jenkins-setup.yaml -i ansible-inventory.yaml
```
# What does it do? 