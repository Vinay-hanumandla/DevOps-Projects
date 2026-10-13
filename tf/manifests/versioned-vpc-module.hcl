# last_verified: 2026-10-13 · tf n/a
#
# Reusable versioned VPC module: multi-AZ public/private subnets with
# internet gateway, per-AZ (or single) NAT gateways, and route composition.
#
# Layout: this single file holds the module's interface (variables), the
# network resources, and the output contract. A root module consumes a pinned
# copy, e.g. source = "git::<repo-url>//modules/vpc?ref=<release-tag>",
# so every environment upgrades the network only by bumping the ref.
# Use one NAT gateway per AZ for AZ-independent egress; set
# single_nat_gateway = true only where cost matters more than that isolation.

# ---------------------------------------------------------------------------
# Variables
# ---------------------------------------------------------------------------

variable "project_name" {
  description = "Name prefix applied to every resource Name tag in this module"
  type        = string

  validation {
    condition     = length(trimspace(var.project_name)) > 0
    error_message = "project_name must be a non-empty string."
  }
}

variable "environment" {
  description = "Environment label, e.g. dev, staging, prod"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block, e.g. 10.0.0.0/16."
  }
}

variable "az_count" {
  description = "How many availability zones to spread subnets across"
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 1 && var.az_count <= 4
    error_message = "az_count must be between 1 and 4."
  }
}

variable "public_newbits" {
  description = "Extra prefix bits for each public subnet, relative to vpc_cidr"
  type        = number
  default     = 8

  validation {
    condition     = var.public_newbits >= 4 && var.public_newbits <= 12
    error_message = "public_newbits must be between 4 and 12."
  }
}

variable "private_newbits" {
  description = "Extra prefix bits for each private subnet, relative to vpc_cidr"
  type        = number
  default     = 8

  validation {
    condition     = var.private_newbits >= 4 && var.private_newbits <= 12
    error_message = "private_newbits must be between 4 and 12."
  }
}

variable "enable_nat" {
  description = "Whether private subnets get NAT egress at all"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use one shared NAT gateway instead of one per AZ (cheaper, AZ-dependent)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Extra tags merged into every resource in this module"
  type        = map(string)
  default     = {}
}

# ---------------------------------------------------------------------------
# Locals
# ---------------------------------------------------------------------------

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs        = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  name       = "${var.project_name}-${var.environment}"
  nat_count  = var.enable_nat ? (var.single_nat_gateway ? 1 : var.az_count) : 0
  base_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# ---------------------------------------------------------------------------
# Network resources
# ---------------------------------------------------------------------------

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.base_tags, var.tags, { Name = "${local.name}-vpc" })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.base_tags, var.tags, { Name = "${local.name}-igw" })
}

resource "aws_subnet" "public" {
  count = var.az_count

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, var.public_newbits, count.index)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.base_tags, var.tags, { Name = "${local.name}-public-${local.azs[count.index]}" })
}

resource "aws_subnet" "private" {
  count = var.az_count

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, var.private_newbits, count.index + var.az_count)
  availability_zone = local.azs[count.index]

  tags = merge(local.base_tags, var.tags, { Name = "${local.name}-private-${local.azs[count.index]}" })
}

resource "aws_eip" "nat" {
  count = local.nat_count

  domain = "vpc"

  tags = merge(local.base_tags, var.tags, { Name = "${local.name}-nat-eip-${count.index}" })
}

resource "aws_nat_gateway" "this" {
  count = local.nat_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[var.single_nat_gateway ? 0 : count.index].id

  tags = merge(local.base_tags, var.tags, { Name = "${local.name}-nat-${count.index}" })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.base_tags, var.tags, { Name = "${local.name}-public" })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count = var.az_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count = var.az_count

  vpc_id = aws_vpc.this.id

  tags = merge(local.base_tags, var.tags, { Name = "${local.name}-private-${local.azs[count.index]}" })
}

resource "aws_route" "private_nat" {
  count = var.enable_nat ? var.az_count : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[var.single_nat_gateway ? 0 : count.index].id
}

resource "aws_route_table_association" "private" {
  count = var.az_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "azs" {
  description = "Availability zones the subnets were spread across"
  value       = local.azs
}

output "public_subnet_ids" {
  description = "IDs of the public subnets, one per AZ"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets, one per AZ"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "ID of the internet gateway"
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT gateways (empty when enable_nat is false)"
  value       = aws_nat_gateway.this[*].id
}

output "public_route_table_id" {
  description = "ID of the shared public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "IDs of the per-AZ private route tables"
  value       = aws_route_table.private[*].id
}

# ---------------------------------------------------------------------------
# Notes
# ---------------------------------------------------------------------------
# - Public subnets take the low cidrsubnet indexes, private subnets are offset
#   by az_count so the two ranges never overlap as az_count changes.
#   Keep public_newbits and private_newbits equal unless the resulting ranges
#   have been checked by hand; different prefix lengths can overlap despite
#   the index offset.
# - Private route tables are one per AZ so each AZ keeps working when its own
#   NAT gateway is used; with single_nat_gateway the routes all point at index 0.
# - With enable_nat = false the private subnets are isolated (no default route);
#   add explicit routes or endpoints for whatever those workloads must reach.
# - Downstream modules (compute, data) take private_subnet_ids and vpc_id as
#   inputs; they never create subnets themselves, which keeps the AZ mapping
#   in exactly one place.
# - The region must have at least az_count available zones; slice fails
#   otherwise, so keep az_count at or below what the region offers.
