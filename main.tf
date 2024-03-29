provider "aws" {
  region = "eu-central-1"
}

module "setup" {
  source = "./modules"
  jenkins_ip = module.setup.ec2_instance_ip
  jenkins_sec_grp = module.setup.jenkins_sec_grp
}

output "jenkins_host" {
    value = "${module.setup.ec2_instance_hostname}"
}

output "docker_host" {
    value = "${module.setup.docker_hostname}"
}
