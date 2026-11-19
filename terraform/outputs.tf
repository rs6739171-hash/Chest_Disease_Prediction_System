output "asg_id" {
  description = "The ID of the Auto Scaling Group"
  value       = aws_autoscaling_group.app_asg.id
}

output "asg_name" {
  description = "The name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app_asg.name
}

output "asg_arn" {
  description = "The ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.app_asg.arn
}

output "launch_template_id" {
  description = "The ID of the Launch Template"
  value       = aws_launch_template.asg_launch_template.id
}

output "launch_template_latest_version" {
  description = "The latest version of the Launch Template"
  value       = aws_launch_template.asg_launch_template.latest_version
}

output "security_group_id" {
  description = "The ID of the Security Group attached to ASG instances"
  value       = aws_security_group.asg_sg.id
}

# =============================================================================
# Pulled Existing Networking Details
# =============================================================================
output "all_discovered_vpc_ids" {
  description = "All available VPC IDs discovered in ap-south-1"
  value       = data.aws_vpcs.all_custom.ids
}

output "pulled_vpc_id" {
  description = "The ID of the discovered existing VPC"
  value       = data.aws_vpc.existing.id
}

output "pulled_vpc_cidr_block" {
  description = "The primary CIDR block of the discovered VPC"
  value       = data.aws_vpc.existing.cidr_block
}

output "pulled_subnet_ids" {
  description = "The list of Subnet IDs discovered within the VPC"
  value       = data.aws_subnets.existing.ids
}

output "pulled_subnet_details" {
  description = "Detailed mapping of discovered subnets (CIDR, Availability Zone, Name)"
  value = {
    for id, s in data.aws_subnet.details : id => {
      cidr_block        = s.cidr_block
      availability_zone = s.availability_zone
      name              = lookup(s.tags, "Name", "unnamed")
    }
  }
}

output "pulled_internet_gateway_id" {
  description = "The ID of the Internet Gateway attached to the discovered VPC"
  value       = data.aws_internet_gateway.existing.id
}

output "pulled_route_table_ids" {
  description = "The IDs of the Route Tables belonging to the discovered VPC"
  value       = data.aws_route_tables.existing.ids
}
