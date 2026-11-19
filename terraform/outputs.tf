# =============================================================================
# Outputs: Pulled Network Resources & Created ASG Infrastructure
# =============================================================================

output "pulled_vpc_id" {
  description = "ID of the existing VPC pulled via data sources"
  value       = data.aws_vpc.existing.id
}

output "pulled_vpc_cidr_block" {
  description = "CIDR block of the existing VPC"
  value       = data.aws_vpc.existing.cidr_block
}

output "pulled_subnet_ids" {
  description = "List of subnet IDs pulled from the VPC"
  value       = data.aws_subnets.existing.ids
}

output "pulled_subnet_details" {
  description = "Detailed mapping of discovered subnets (AZ, CIDR, Name tag)"
  value = {
    for id, subnet in data.aws_subnet.details : id => {
      cidr_block        = subnet.cidr_block
      availability_zone = subnet.availability_zone
      name              = lookup(subnet.tags, "Name", id)
    }
  }
}

output "pulled_route_table_ids" {
  description = "IDs of the existing route tables pulled for the VPC"
  value       = data.aws_route_tables.existing.ids
}

output "pulled_internet_gateway_id" {
  description = "ID of the existing Internet Gateway attached to the VPC"
  value       = data.aws_internet_gateway.existing.id
}

output "security_group_id" {
  description = "ID of the created ASG security group"
  value       = aws_security_group.asg_sg.id
}

output "launch_template_id" {
  description = "ID of the created Launch Template"
  value       = aws_launch_template.asg_launch_template.id
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app_asg.name
}

output "asg_id" {
  description = "ID of the Auto Scaling Group"
  value       = aws_autoscaling_group.app_asg.id
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.app_asg.arn
}
