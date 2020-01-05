# base-vpc-network
- Builds a basic VPC network for testing, etc.
- Terraform 0.12
- Additional network resources can - and probably should - be applied to this base layer
- Builds:
    - VPC
    - Public subnets
    - Private subnets
    - Internet Gateway
    - NAT gateway
    - Route tables for public and private subnets

## Inputs
- "project_name" : description = "A project name to associate with resources"
- "terraform_project" : description = "Name of the Terraform project"
- "dns_support" : default = true
- "dns_hostnames" : default = true
- "num_public_subnets" : default = 2
- "num_private_subnets" : default = 2
- "cidr_block" : default = "10.0.0.0/16"
- "assign_pub_ip" : type = bool default = false

## Outputs
- "vpc_id" : value = aws_vpc.vpc.id 
- "vpc_cidr" : value = aws_vpc.vpc.cidr_block
- "cidr" : value = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 0)
- "public_subnet_ids" : value = aws_subnet.public_subnets[*].id
- "private_subnet_ids" : value = aws_subnet.private_subnets[*].id
- "default_sec_group_id" : value = aws_vpc.vpc.default_security_group_id
- "public_route_table_id" : value = aws_route_table.public_route_table.id
- "private_route_table_id" : value = aws_route_table.private_route_table.id
