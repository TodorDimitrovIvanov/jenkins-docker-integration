# What is this? 
This repo sets up CI/CD infrastructure using IaaC for an example NodeJS app on AWS. It provisions 2 tiny EC2 instances - one running Jenkins and one running Docker. The Docker EC2 instance creates containers for Jenkins builds of the NodeJS app.  
# What tech stack is used? 
SCM: GitHub  
Provisioning: Terraform  
Configuration management: Ansible  
Automation server:  Jenkins  
Containereztion: Docker  

# How to setup? 
## Quicksetup
Run the following one-liner:
```
terraform init; terraform apply -auto-approve; jenkins_ip=$(tf state show module.setup.aws_instance.jenkins-master | grep "public_dns" | awk '{printf $3}' | sed 's/"//g'); docker_ip=$(tf state show module.setup.aws_instance.docker-runner | grep "public_dns" | awk '{printf $3}' | sed 's/"//g'); sed -i "s/JENKINS-PLACEHOLDER/$jenkins_ip/g" ansible-inventory.yaml; sed -i "s/DOCKER-PLACEHOLDER/$docker_ip/g" ansible-inventory.yaml; ansible-playbook jenkins-setup.yaml -i inventory.yaml; ansible-playbook docker-setup.yaml -i inventory.yaml
```
## Terraform
This is the middleware that connects to AWS and provisions the EC2 instances. To run it, we simply have to execute the following commands:
```
terraform init
terraform plan (Optional preview)
terraform apply 
```
## Ansible 
For the setup of Jenkins and Docker we first need to retrieve both EC2 instances' hostnames from the Terraform output and place then in the ansible inventory
```
sed -i 's/JENKINS-PLACEHOLDER/_____HOST_____/g' inventory.yaml
```
```
sed -i 's/DOCKER-PLACEHOLDER/_____HOST_____/g' inventory.yaml
```
Then we can start the configuration process with:  
```
ansible-playbook jenkins-setup.yaml -i inventory.yaml
```
```
ansible-playbook docker-setup.yaml -i inventory.yaml
```
## Jenkins 
* After the Ansible play is completed, it will print the Jenkins admin password - be sure to change it. Then we login and install the following Jenkins plugins: 
  * Docker
  * Docker Pipeline
* Next under "Manage Jenkins" select "Clouds" and "New Cloud" then "Docker" and give it a name 
* Upload a private key for GitHub authentication as  secret under Jenkins's Credentials menu
* Finally, set up a new pipeline job 
  * Add the NodeJS App GitHub repo as SCM source:
    ```
    https://github.com/TodorDimitrovIvanov/aws-elastic-beanstalk-express-js-sample
    ```
  * Set the starting script to 'pipeline.groovy'
  * Run the pipeline