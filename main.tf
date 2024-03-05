provider "aws" {
  region = "eu-central-1"
}

module "setup" {
  source = "./modules"
  jenkins_sec_grp = module.setup.jenkins_sec_grp
  grafana_sec_grp = module.setup.grafana_sec_grp
  prometheus_sec_grp = module.setup.prometheus_sec_grp
}

variable "ami" {
  type = string
  default = {
    "debian" = "ami-042e6fdb154c830c5"
  }
}

output "jenkins_host" {
    value = "${module.setup.ec2_instance_hostname}"
}

output "docker_host" {
    value = "${module.setup.docker_hostname}"
}

output "grafana_host" {
  value = "${module.setup.grafana-ec2}"
}

output "prometheus_host" {
  value = "${module.setup.prometheus-ec2}"
}