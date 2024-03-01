# How to setup? 
## Quicksetup
Run the following command:
```
terraform init; terraform apply -auto-approve; host_ip=$(tf output -raw ec2_instance_hostname); docker_ip=$(tf output -raw docker_hostname); sed -i "s/JENKINS-PLACEHOLDER/$host_ip/g" ansible-inventory.yaml; sed -i "s/DOCKER-PLACEHOLDER/$docker_ip/g" ansible-inventory.yaml;ansible-playbook jenkins-setup.yaml -i inventory.yaml
```
## Terraform
This is the middleware that connects to AWS and deploys the EC2 instance. To run it, we simply have to execute the following commands:
```
terraform init
terraform plan
terraform apply 
```
## Ansible 
To setup Jenkins on the EC2 instance we first need to retrieve its and Docker's Hostnames from the Terraform output and replace it in the ansible inventory
```
sed -i 's/JENKINS-PLACEHOLDER/_____HOST_____/g'
```
```
sed -i 's/DOCKER-PLACEHOLDER/_____HOST_____/g'
```
And then start the process with: 
```
ansible-playbook jenkins-setup.yaml -i inventory.yaml
```
# What does it do? 