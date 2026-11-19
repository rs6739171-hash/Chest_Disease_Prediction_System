# =============================================================================
# Discover and Pull Existing Network Infrastructure (VPC, Subnets, IGW, RTBs)
# =============================================================================

# Query custom non-default VPCs created in previous deployments
data "aws_vpcs" "custom_vpcs" {
  filter {
    name   = "isDefault"
    values = ["false"]
  }
}

# Fallback query in case only default VPC exists
data "aws_vpcs" "all_vpcs" {}

locals {
  discovered_vpc_id = length(data.aws_vpcs.custom_vpcs.ids) > 0 ? tolist(data.aws_vpcs.custom_vpcs.ids)[0] : tolist(data.aws_vpcs.all_vpcs.ids)[0]
  selected_vpc_id   = var.vpc_id != "" ? var.vpc_id : local.discovered_vpc_id
}

# Pull existing VPC attributes
data "aws_vpc" "existing" {
  id = local.selected_vpc_id
}

# Pull existing subnets associated with the selected VPC
data "aws_subnets" "existing" {
  filter {
    name   = "vpc-id"
    values = [local.selected_vpc_id]
  }
}

# Pull individual details (CIDR, AZ, Tags) for each subnet
data "aws_subnet" "details" {
  for_each = toset(data.aws_subnets.existing.ids)
  id       = each.value
}

# Pull existing route tables for the selected VPC
data "aws_route_tables" "existing" {
  filter {
    name   = "vpc-id"
    values = [local.selected_vpc_id]
  }
}

# Pull existing internet gateway attached to the selected VPC
data "aws_internet_gateway" "existing" {
  filter {
    name   = "attachment.vpc-id"
    values = [local.selected_vpc_id]
  }
}

# =============================================================================
# Pull Latest Ubuntu 22.04 LTS Official Canonical AMI
# =============================================================================
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical official account

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
