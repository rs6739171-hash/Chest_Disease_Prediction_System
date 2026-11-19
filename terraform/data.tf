# =============================================================================
# Terraform Data Sources: Pull Existing AWS Networking Details
# Region: ap-south-1
# =============================================================================

# 1. Query available VPCs (uses plural data source to avoid "multiple VPCs matched" error)
data "aws_vpcs" "all_custom" {
  filter {
    name   = "state"
    values = ["available"]
  }

  # If a Name tag filter is supplied, match only VPCs with that tag
  dynamic "filter" {
    for_each = var.vpc_name_tag != "" ? [1] : []
    content {
      name   = "tag:Name"
      values = [var.vpc_name_tag]
    }
  }
}

locals {
  # Priority resolution:
  # 1. If var.vpc_id is explicitly set, use it.
  # 2. Otherwise safely take the first matching VPC from the discovered list.
  selected_vpc_id = var.vpc_id != "" ? var.vpc_id : (
    length(data.aws_vpcs.all_custom.ids) > 0 ? tolist(data.aws_vpcs.all_custom.ids)[0] : null
  )
}

# 2. Pull detailed attributes for the selected VPC ID
data "aws_vpc" "existing" {
  id = local.selected_vpc_id
}

# 3. Pull Existing Subnets belonging to the selected VPC
data "aws_subnets" "existing" {
  filter {
    name   = "vpc-id"
    values = [local.selected_vpc_id]
  }

  # Optional tag filter (e.g. to filter public subnets only)
  dynamic "filter" {
    for_each = var.subnet_name_tag != "" ? [1] : []
    content {
      name   = "tag:Name"
      values = [var.subnet_name_tag]
    }
  }
}

# 4. Pull individual details (CIDR, Availability Zone, Tags) for discovered Subnets
data "aws_subnet" "details" {
  for_each = toset(data.aws_subnets.existing.ids)
  id       = each.value
}

# 5. Pull Existing Internet Gateway attached to the selected VPC
data "aws_internet_gateway" "existing" {
  filter {
    name   = "attachment.vpc-id"
    values = [local.selected_vpc_id]
  }
}

# 6. Pull Existing Route Tables belonging to the selected VPC
data "aws_route_tables" "existing" {
  vpc_id = local.selected_vpc_id
}
