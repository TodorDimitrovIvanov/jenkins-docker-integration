resource "aws_security_group" "prometheus_sec_grp" {
  name = "prometheus_sec_grp"
  description = "Security group for Prometheus EC2 instances"

  # Allow SSH access for configuration
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow all external traffic 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "prometheus-ec2" {
  ami = "${var.ami["debian"]}"
  instance_type = "t2.micro"
  key_name = aws_key_pair.ec2_pub_key.key_name
}

variable grafana_sec_grp {
  type = string
}

output "prometheus_hostname" {
  value = aws_instance.prometheus-ec2.public_dns
}

output "prometheus_sec_grp"{
  value = aws_security_group.prometheus_sec_grp.id
}