output "vpc_id" {
  value = aws_vpc.vpc.id 
}

output "vpc_cidr" {
    value = aws_vpc.vpc.cidr_block
}

output "cidr" {
    value = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 0)
}

# output "az" {
#     value = data.aws_availability_zones.azs.names
# }

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "default_sec_group_id" {
  value = aws_vpc.vpc.default_security_group_id
}

# output "az_idx" {
#     value = (var.num_public_subnets + var.num_private_subnets)%2 > 0 ? true : false
# }

output "public_route_table_id" {
  value = aws_route_table.public_route_table.id
}

output "private_route_table_id" {
  value = aws_route_table.private_route_table.id
}

output "ssh_security_group_id" {
  value = aws_security_group.allow_ssh.id
}
