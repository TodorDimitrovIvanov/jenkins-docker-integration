resource "aws_security_group" "grafana_sec_grp" {
  name = "grafana_sec_grp"
  description = "Security group for Grafana EC2 instances"

  # Allow SSH access for configuration
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow all access from Prometheus EC2 instance
  ingress = {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    security_groups = ["${var.prometheus_sec_grp}"] 
  }
  # Allow all external traffic 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "grafana-ec2" {
  ami = "${var.ami["debian"]}"
  instance_type = "t2.micro"
  key_name = aws_key_pair.ec2_pub_key.key_name
}

variable prometheus_sec_grp {
  type = string
}

output "grafana_host" {
  value = aws_instance.grafana-ec2.public_dns
}

output "grafana_sec_grp"{
  value = aws_security_group.grafana_sec_grp.id
}