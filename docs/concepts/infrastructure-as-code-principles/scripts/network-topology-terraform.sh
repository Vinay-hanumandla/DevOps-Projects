#!/usr/bin/env bash
# network-topology-terraform.sh
# Generate a small Terraform network topology (VPC + public/private subnets +
# default route), driven entirely by parameters.
#
# This is the IaC + Networking pattern in miniature: the network is described
# declaratively in code, and the same script shapes every environment, only
# with different parameter values.

set -euo pipefail

NET_NAME="${1:-demo}"
VPC_CIDR="${2:-10.0.0.0/16}"
OUT_DIR="${3:-./out}"

cidr_to_prefix() {
  local cidr="$1"
  python3 -c "
import ipaddress, sys
try:
  net = ipaddress.ip_network(sys.argv[1], strict=False)
  print(net.prefixlen)
except Exception:
  pass
" "$cidr"
}

next_subnet() {
  local base="$1"
  local newbits="$2"
  python3 -c "
import ipaddress, sys
base = ipaddress.ip_network(sys.argv[1], strict=False)
subnets = list(base.subnets(new_prefix=base.prefixlen + int(sys.argv[2])))
print(str(subnets[0]))
" "$base" "$newbits"
}

subnet_nth() {
  local base="$1"
  local newbits="$2"
  local idx="$3"
  python3 -c "
import ipaddress, sys
base = ipaddress.ip_network(sys.argv[1], strict=False)
subnets = list(base.subnets(new_prefix=base.prefixlen + int(sys.argv[2])))
print(str(subnets[int(sys.argv[3])]))
" "$base" "$newbits" "$idx"
}

mkdir -p "$OUT_DIR"
TF_FILE="${OUT_DIR}/network.tf"

{
  echo 'resource "aws_vpc" "main" {'
  echo "  cidr_block = \"${VPC_CIDR}\""
  echo "  tags = { Name = \"${NET_NAME}-vpc\" }"
  echo '}'
  echo ''

  echo 'resource "aws_internet_gateway" "igw" {'
  echo '  vpc_id = aws_vpc.main.id'
  echo "  tags = { Name = \"${NET_NAME}-igw\" }"
  echo '}'
  echo ''

  local_base=$(next_subnet "$VPC_CIDR" 2)
  pub0=$(subnet_nth "$local_base" 1 0)
  pub1=$(subnet_nth "$local_base" 1 1)
  priv0=$(subnet_nth "$local_base" 2 2)
  priv1=$(subnet_nth "$local_base" 2 3)

  echo 'resource "aws_subnet" "public_0" {'
  echo '  vpc_id                  = aws_vpc.main.id'
  echo "  cidr_block              = \"${pub0}\""
  echo '  map_public_ip_on_launch = true'
  echo "  tags = { Name = \"${NET_NAME}-public-0\" }"
  echo '}'
  echo ''
  echo 'resource "aws_subnet" "public_1" {'
  echo '  vpc_id                  = aws_vpc.main.id'
  echo "  cidr_block              = \"${pub1}\""
  echo '  map_public_ip_on_launch = true'
  echo "  tags = { Name = \"${NET_NAME}-public-1\" }"
  echo '}'
  echo ''
  echo 'resource "aws_subnet" "private_0" {'
  echo '  vpc_id     = aws_vpc.main.id'
  echo "  cidr_block = \"${priv0}\""
  echo "  tags = { Name = \"${NET_NAME}-private-0\" }"
  echo '}'
  echo ''
  echo 'resource "aws_subnet" "private_1" {'
  echo '  vpc_id     = aws_vpc.main.id'
  echo "  cidr_block = \"${priv1}\""
  echo "  tags = { Name = \"${NET_NAME}-private-1\" }"
  echo '}'
  echo ''

  echo 'resource "aws_route_table" "public" {'
  echo '  vpc_id = aws_vpc.main.id'
  echo '  route {'
  echo '    cidr_block = "0.0.0.0/0"'
  echo '    gateway_id = aws_internet_gateway.igw.id'
  echo '  }'
  echo "  tags = { Name = \"${NET_NAME}-public-rt\" }"
  echo '}'
  echo ''

  echo 'resource "aws_route_table_association" "public_0" {'
  echo '  subnet_id      = aws_subnet.public_0.id'
  echo '  route_table_id = aws_route_table.public.id'
  echo '}'
  echo 'resource "aws_route_table_association" "public_1" {'
  echo '  subnet_id      = aws_subnet.public_1.id'
  echo '  route_table_id = aws_route_table.public.id'
  echo '}'
} > "$TF_FILE"

echo "wrote $TF_FILE"
