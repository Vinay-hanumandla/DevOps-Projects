# last_verified: 2026-09-19 · terraform n/a
#
# AWS VPC module with public/private subnets and NAT gateway (L3 reference)
# Uses for_each + data-driven AZ discovery instead of count + hardcoded AZs.
# Consumed via:
#   module "vpc" {
#     source       = "./vpc"
#     project_name = "my-app"
#     vpc_cidr     = "10.10.0.0/16"
#   }

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ---------------------------------------------------------------------------
# Data sources
# ---------------------------------------------------------------------------

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {}

# ---------------------------------------------------------------------------
# Variables
# ---------------------------------------------------------------------------

variable "project_name" {
  description = "Name prefix applied to all resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets — one per AZ"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets — one per AZ"
  type        = list(string)
  default     = ["10.0.16.0/24", "10.0.17.0/24"]
}

variable "enable_nat_gateway" {
  description = "Create NAT gateways so private subnets can reach the internet"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway shared across all AZs (lower cost, SPOF)"
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Enable VPC flow logs to CloudWatch Logs"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Extra tags merged onto every resource"
  type        = map(string)
  default     = {}
}

# ---------------------------------------------------------------------------
# Locals
# ---------------------------------------------------------------------------

locals {
  az_names = slice(data.aws_availability_zones.available.names, 0, length(var.private_subnet_cidrs))

  common_tags = merge(var.tags, {
    Project   = var.project_name
    ManagedBy = "terraform"
  })

  # AZs that get a NAT gateway — all AZs by default, or just the first when single_nat_gateway
  nat_azs = var.enable_nat_gateway
    ? (var.single_nat_gateway ? [local.az_names[0]] : local.az_names)
    : []
}

# ---------------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------------

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = merge(local.common_tags, { Name = "${var.project_name}-vpc" })
}

# ---------------------------------------------------------------------------
# Flow logs (CloudWatch Logs)
# ---------------------------------------------------------------------------

resource "aws_flow_log" "vpc" {
  for_each = var.enable_flow_logs ? { vpc = aws_vpc.this.id } : {}

  iam_role_arn    = aws_iam_role.flow_logs[each.key].arn
  log_destination = aws_cloudwatch_log_group.vpc[each.key].arn
  traffic_type    = "ALL"
  vpc_id          = each.value

  tags = merge(local.common_tags, { Name = "${var.project_name}-flow-log" })
}

resource "aws_iam_role" "flow_logs" {
  for_each = var.enable_flow_logs ? { vpc = aws_vpc.this.id } : {}

  name = "${var.project_name}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "flow_logs" {
  for_each = var.enable_flow_logs ? { vpc = aws_vpc.this.id } : {}

  role       = aws_iam_role.flow_logs[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonVPCFlowLogsRolePolicyForCW"
}

resource "aws_cloudwatch_log_group" "vpc" {
  for_each = var.enable_flow_logs ? { vpc = aws_vpc.this.id } : {}

  name              = "/aws/vpc/${var.project_name}"
  retention_in_days = 30

  tags = local.common_tags
}

# ---------------------------------------------------------------------------
# Internet Gateway
# ---------------------------------------------------------------------------

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, { Name = "${var.project_name}-igw" })
}

# ---------------------------------------------------------------------------
# Public subnets
# ---------------------------------------------------------------------------

resource "aws_subnet" "public" {
  for_each = { for i, cidr in var.public_subnet_cidrs : local.az_names[i] => cidr if i < length(local.az_names) }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-${each.key}"
    Tier = "public"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(local.common_tags, { Name = "${var.project_name}-public-rt" })
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------------------------------------
# Private subnets + NAT
# ---------------------------------------------------------------------------

resource "aws_subnet" "private" {
  for_each = { for i, cidr in var.private_subnet_cidrs : local.az_names[i] => cidr if i < length(local.az_names) }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-private-${each.key}"
    Tier = "private"
  })
}

resource "aws_eip" "nat" {
  for_each = { for az in local.nat_azs : az => az }

  domain = "vpc"

  tags = merge(local.common_tags, { Name = "${var.project_name}-nat-eip-${each.key}" })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  for_each = aws_eip.nat

  allocation_id = each.value.id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(local.common_tags, { Name = "${var.project_name}-nat-${each.key}" })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-private-rt-${each.value.availability_zone}"
  })
}

resource "aws_route" "private_default" {
  for_each = aws_route_table.private

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = var.single_nat_gateway
    ? aws_nat_gateway.this[local.az_names[0]].id
    : aws_nat_gateway.this[each.key].id

  depends_on = [aws_route_table.private]
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "ARN of the created VPC"
  value       = aws_vpc.this.arn
}

output "public_subnet_ids" {
  description = "IDs of public subnets, keyed by AZ name"
  value       = { for k, v in aws_subnet.public : k => v.id }
}

output "private_subnet_ids" {
  description = "IDs of private subnets, keyed by AZ name"
  value       = { for k, v in aws_subnet.private : k => v.id }
}

output "internet_gateway_id" {
  description = "ID of the internet gateway"
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_ids" {
  description = "IDs of NAT gateways"
  value       = [for ngw in aws_nat_gateway.this : ngw.id]
}

output "public_route_table_id" {
  description = "ID of the shared public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "IDs of private route tables, keyed by AZ name"
  value       = { for k, v in aws_route_table.private : k => v.id }
}

output "availability_zones" {
  description = "AZ names used for subnet placement"
  value       = local.az_names
}
