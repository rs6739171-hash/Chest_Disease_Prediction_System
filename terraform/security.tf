# Security Group for Auto Scaling Group EC2 Instances
resource "aws_security_group" "asg_sg" {
  name_prefix = "${var.project_name}-asg-sg-"
  description = "Security group for Chest Disease Prediction ASG instances"
  vpc_id      = data.aws_vpc.existing.id

  # Ingress for Flask Web Application
  ingress {
    description = "Allow inbound traffic to Flask Web App on port 8080"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress for HTTP
  ingress {
    description = "Allow inbound HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress for HTTPS
  ingress {
    description = "Allow inbound HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress for SSH (Optional - SSM Session Manager is preferred)
  ingress {
    description = "Allow SSH from anywhere (restrict in production)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-asg-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}
