# What is this? 
This repo sets up CI/CD infrastructure using IaaC for an example NodeJS app on AWS. It provisions 2 tiny EC2 instances - one running Jenkins and one running Docker. The Docker EC2 instance creates containers for Jenkins builds of the NodeJS app. Additionally, a Grafana & Prometheus stack is deployed for monitoring and logging Jenkins's data   
# What tech stack is used? 
SCM: GitHub  
Provisioning: Terraform  
Configuration management: Ansible  
Automation server:  Jenkins  
Containereztion: Docker  
Data collection: Prometheus 
Data monitoring: Grafana 

# How to setup? 
## Quicksetup
Run the following one-liner:
```
terraform init; terraform apply -auto-approve; 
jenkins_ip=$(tf state show module.setup.aws_instance.jenkins-master | grep "public_dns" | awk '{printf $3}' | sed 's/"//g');
docker_ip=$(tf state show module.setup.aws_instance.docker-runner | grep "public_dns" | awk '{printf $3}' | sed 's/"//g');
grafana_ip=$(tf state show module.setup.aws_instance.grafana-ec2 | grep "public_dns" | awk '{printf $3}' | sed 's/"//g');
prometheus_ip=$(tf state show module.setup.aws_instance.prometheus-ec2 | grep "public_dns" | awk '{printf $3}' | sed 's/"//g');
sed -i "s/JENKINS-PLACEHOLDER/$jenkins_ip/g" playbooks/inventory.yaml;
sed -i "s/DOCKER-PLACEHOLDER/$docker_ip/g" playbooks/inventory.yaml;
sed -i "s/GRAFANA-PLACEHOLDER/$grafana_ip/g" playbooks/inventory.yaml;
sed -i "s/PROMETHEUS-PLACEHOLDER/$prometheus_ip/g" playbooks/inventory.yaml;
sed -i "s/JENKINS-PLACEHOLDER/$jenkins_ip/g" playbooks/files/prometheus.yaml;
ansible-playbook playbooks/jenkins-setup.yaml -i playbooks/inventory.yaml;
ansible-playbook playbooks/docker-setup.yaml -i playbooks/inventory.yaml
ansible-playbook playbooks/grafana-setup.yaml -i playbooks/inventory.yaml;
ansible-playbook playbooks/prometheus-setup.yaml -i playbooks/nventory.yaml

```
## Terraform
This is the middleware that connects to AWS and provisions the EC2 instances. To run it, we simply have to execute the following commands:
```
terraform init
terraform plan (Optional preview)
terraform apply 
```
## Ansible
This is the configuration management tool that's responsible for setting up the CI/CD pipeline and containers. For the setup of Jenkins and Docker we first need to retrieve both EC2 instances' hostnames from the Terraform output and place then in the ansible inventory
```
jenkins_ip=$(tf state show module.setup.aws_instance.jenkins-master | grep "public_dns" | awk '{printf $3}' | sed 's/"//g');
docker_ip=$(tf state show module.setup.aws_instance.docker-runner | grep "public_dns" | awk '{printf $3}' | sed 's/"//g');
sed -i 's/JENKINS-PLACEHOLDER/_____HOST_____/g' iplaybooks/inventory.yaml
sed -i 's/DOCKER-PLACEHOLDER/_____HOST_____/g' playbooks/inventory.yaml
```
Then we can start the configuration process with:  
```
ansible-playbook playbooks/jenkins-setup.yaml -i playbooks/inventory.yaml
ansible-playbook playbooks/docker-setup.yaml -i playbooks/inventory.yaml
```
## Jenkins 
This is the automation server that will build new versions of the NodeJS app
* After the Ansible play is completed, it will print the Jenkins admin password - be sure to change it. Then we login and install the following Jenkins plugins: 
  * Docker
  * Docker Pipeline
  * Prometheus Metrics
* Next under "Manage Jenkins" select "Clouds" and "New Cloud" then "Docker" and give it a name 
* Upload a private key for GitHub authentication as  secret under Jenkins's Credentials menu
* Finally, set up a new pipeline job 
  * Add the NodeJS App GitHub repo as SCM source:
    ```
    https://github.com/TodorDimitrovIvanov/aws-elastic-beanstalk-express-js-sample
    ```
  * Set the starting script to 'pipeline.groovy'
  * Run the pipeline
# Grafana & Prometheus 
These are the data metrics and data gathering services that will be used for gathering Jenkins' data. To start the setup process, complete the following commands:
```
grafana_ip=$(tf state show module.setup.aws_instance.grafana-ec2 | grep "public_dns" | awk '{printf $3}' | sed 's/"//g');
prometheus_ip=$(tf state show module.setup.aws_instance.prometheus-ec2 | grep "public_dns" | awk '{printf $3}' | sed 's/"//g');
sed -i 's/JENKINS-PLACEHOLDER/_____HOST_____/g' playbooks/inventory.yaml
sed -i "s/PROMETHEUS-PLACEHOLDER/_____HOST_____/g" playbooks/inventory.yaml;
sed -i "s/JENKINS-PLACEHOLDER/_____HOST_____/g" playbooks/files/prometheus.yaml
```
```
ansible-playbook playbooks/grafana-setup.yaml -i playbooks/inventory.yaml;
ansible-playbook playbooks/prometheus-setup.yaml -i playbooks/inventory.yaml
```
* After the setup is completed, Prometheus should automatically connect to Jenkins and start gathering data from it. 
* However we still need to configure the Prometheus EC2 instance within Grafana. This is done by: 
  * First creating a new Dashboard 
  * Then configuring the Prometheus EC2 hostname as Data Source
  * Adding visualization for different data