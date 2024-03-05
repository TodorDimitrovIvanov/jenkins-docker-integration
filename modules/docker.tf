
resource "aws_security_group" "incoming_docker_access" {
  name        = "incoming_docker_access"
  description = "Allow inbound container requests"

  ingress {
    from_port   = 4243
    to_port     = 4243
    protocol    = "tcp"
    security_groups = ["${var.jenkins_sec_grp}"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from any IP address (make sure to restrict this in production)
  }
}

resource "aws_instance" "docker-runner" {
  ami = "${var.ami["debian"]}"
  instance_type = "t2.micro"
  key_name = aws_key_pair.ec2_pub_key.key_name

  vpc_security_group_ids = [aws_security_group.incoming_docker_access.id]
}

output "docker_hostname" {
  value = aws_instance.docker-runner.public_dns
}

variable jenkins_sec_grp {
  type = string
}