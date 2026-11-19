# =============================================================================
# AMI Data Source (Ubuntu 22.04 LTS for ap-south-1)
# =============================================================================
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical official AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# =============================================================================
# Launch Template
# =============================================================================
resource "aws_launch_template" "asg_launch_template" {
  name_prefix   = "${var.project_name}-lt-"
  description   = "Launch template for Chest Disease Prediction ASG instances"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name != "" ? var.key_name : null

  vpc_security_group_ids = [aws_security_group.asg_sg.id]

  # Cloud-init User Data (with automated GitHub Runner setup)
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    github_repo_url     = var.github_repo_url
    github_runner_token = var.github_runner_token
  }))

  # Storage configuration: 30 GB gp3 root disk for container images and models
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 30
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-asg-instance"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "${var.project_name}-asg-volume"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# =============================================================================
# Auto Scaling Group (Min: 1, Max: 2, Desired: 1)
# =============================================================================
resource "aws_autoscaling_group" "app_asg" {
  name_prefix         = "${var.project_name}-asg-"
  vpc_zone_identifier = length(var.subnet_ids) > 0 ? var.subnet_ids : data.aws_subnets.existing.ids

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true

  launch_template {
    id      = aws_launch_template.asg_launch_template.id
    version = "$Latest"
  }

  # Zero-downtime rolling replacement when launch template changes
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 300
    }
    triggers = ["tag"]
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-node"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

# =============================================================================
# Target Tracking Scaling Policy (Scale based on Average CPU Utilization)
# =============================================================================
resource "aws_autoscaling_policy" "cpu_target_tracking_policy" {
  name                   = "${var.project_name}-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_target_utilization
  }
}
