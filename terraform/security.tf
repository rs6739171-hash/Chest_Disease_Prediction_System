# =============================================================================
# Security Group for Auto Scaling Group Instances
# =============================================================================
resource "aws_security_group" "asg_sg" {
  name_prefix = "${var.project_name}-asg-sg-"
  description = "Security group for Chest Disease Prediction ASG instances"
  vpc_id      = data.aws_vpc.existing.id

  # Port 8080 for Flask prediction dashboard
  ingress {
    description = "Allow inbound Flask app traffic"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Port 80 for HTTP
  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Port 443 for HTTPS
  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Port 22 for SSH management
  ingress {
    description = "Allow SSH management"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound connections
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
