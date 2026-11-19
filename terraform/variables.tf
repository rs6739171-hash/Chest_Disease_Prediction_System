variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name prefix for AWS resources"
  type        = string
  default     = "chest-disease-prediction"
}

variable "environment" {
  description = "Deployment environment (e.g., production, staging)"
  type        = string
  default     = "production"
}

# -----------------------------------------------------------------------------
# Existing Networking Configuration (Auto-discovered if left blank)
# -----------------------------------------------------------------------------
variable "vpc_id" {
  description = "Optional existing VPC ID. If left empty, auto-discovers your previous custom VPC."
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Optional existing subnet IDs list. If left empty, auto-discovers from the selected VPC."
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# EC2 & Auto Scaling Group Parameters
# -----------------------------------------------------------------------------
variable "instance_type" {
  description = "EC2 instance type (t3.medium recommended for deep learning inference)"
  type        = string
  default     = "t3.medium"
}

variable "app_port" {
  description = "Web application listening port"
  type        = number
  default     = 8080
}

variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "cpu_target_utilization" {
  description = "Target CPU utilization percentage for auto scaling policy"
  type        = number
  default     = 70.0
}

# -----------------------------------------------------------------------------
# GitHub Actions Self-Hosted Runner
# -----------------------------------------------------------------------------
variable "github_repo_url" {
  description = "Target GitHub repository URL for the self-hosted runner"
  type        = string
  default     = "https://github.com/rs6739171-hash/Chest_Disease_Prediction_System"
}

variable "github_runner_token" {
  description = "GitHub Actions registration token from Repo Settings -> Actions -> Runners -> New runner"
  type        = string
  default     = "CH4MABIMCQ6WPBK7N7JJYITK736QY"
  sensitive   = true
}
