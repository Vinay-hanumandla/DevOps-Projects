# last_verified: 2026-09-20 · tf n/a
#
# Root module fan-out composition: VPC + EKS + RDS submodules wired via outputs.
# Each submodule owns a focused set of resources; the root module glues them
# together by passing outputs between module blocks.

# ---------------------------------------------------------------------------
# Module blocks
# ---------------------------------------------------------------------------

module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  environments = var.environments

  tags = var.tags
}

module "eks" {
  source = "./modules/eks"

  vpc_id         = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnet_ids
  cluster_name   = "${var.project_name}-eks"

  eks_version = var.eks_version

  tags = var.tags
}

module "rds" {
  source = "./modules/rds"

  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnet_ids
  cluster_name = "${var.project_name}-rds"

  engine         = var.rds_engine
  engine_version = var.rds_engine_version
  instance_class = var.rds_instance_class

  depends_on = [module.eks]

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "vpc_id" {
  description = "VPC ID from the VPC submodule"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "rds_endpoint" {
  description = "RDS cluster endpoint"
  value       = module.rds.rds_endpoint
}

output "rds_reader_endpoint" {
  description = "RDS cluster reader endpoint (if multi-AZ)"
  value       = module.rds.rds_reader_endpoint
}

output "rds_secret_arn" {
  description = "ARN of the secret holding database credentials"
  value       = module.rds.rds_secret_arn
}

# ---------------------------------------------------------------------------
# Notes
# ---------------------------------------------------------------------------
# - The EKS submodule consumes VPC outputs (vpc_id, private_subnet_ids).
# - The RDS submodule consumes VPC outputs and explicitly depends on EKS
#   to ensure the cluster exists before database provisioning begins.
# - Each submodule's outputs are described in its own module manifest;
#   only the values consumed by sibling modules are surfaced here.
