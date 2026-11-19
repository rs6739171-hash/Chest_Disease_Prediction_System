variable "aws_region" {
  description = "AWS Region for deployment"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Name of the project used for resource naming"
  type        = string
  default     = "chest-disease-prediction"
}

# -----------------------------------------------------------------------------
# Existing Networking Inputs (Optional: Leave empty to auto-discover)
# -----------------------------------------------------------------------------
variable "vpc_id" {
  description = "Optional ID of the existing VPC. Leave empty to auto-discover using data sources."
  type        = string
  default     = ""
}

variable "vpc_name_tag" {
  description = "Optional Name tag of the existing VPC to filter by (e.g. 'my-vpc')"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Optional explicit list of subnet IDs. Leave empty to auto-discover from the VPC."
  type        = list(string)
  default     = []
}

variable "subnet_name_tag" {
  description = "Optional Name tag filter for subnets (e.g. '*public*'). Leave empty to pull all subnets in the VPC."
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# EC2 & Auto Scaling Configuration
# -----------------------------------------------------------------------------
variable "instance_type" {
  description = "EC2 instance type (t3.medium recommended for TensorFlow model inference)"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "Optional EC2 Key Pair name for SSH access (leave empty if using SSM Session Manager)"
  type        = string
  default     = null
}

variable "app_port" {
  description = "Port exposed by the Chest Disease Prediction Flask web application"
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
  description = "Target average CPU percentage to trigger auto-scaling"
  type        = number
  default     = 70.0
}

# -----------------------------------------------------------------------------
# GitHub Actions Self-Hosted Runner (Zero-Dashboard Setup)
# -----------------------------------------------------------------------------
variable "github_repo_url" {
  description = "https://github.com/rs6739171-hash/Chest_Disease_Prediction_System"
  type        = string
  default     = "https://github.com/rs6739171-hash/Chest_Disease_Prediction_System"
}

variable "github_runner_token" {
  description = "GitHub Runner Registration Token (obtained from GitHub Repo -> Settings -> Actions -> Runners -> New runner)"
  type        = string
  default     = "CH4MABIHQKOWGGP7YOZGVWLK73UUA"
  sensitive   = true
}
