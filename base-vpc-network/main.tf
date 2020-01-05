terraform {
    required_version = "> 0.12.0"
}

resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_block
    enable_dns_support = var.dns_support
    enable_dns_hostnames = var.dns_hostnames

    tags = merge(
        {"Name" = var.project_name},
        local.common_tags
    )
  
}

##### Subnets
resource "aws_subnet" "public_subnets" {
    count = var.num_public_subnets 

    vpc_id = aws_vpc.vpc.id
    cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)
    # Just assuming 2 AZs for now
    # availability_zone = data.aws_availabilility_zones.azs.names[(var.num_public_subnets + var.num_private_subnets)%2 > 0 ? 0 : 1]
    availability_zone = data.aws_availability_zones.azs.names[count.index%2 > 0 ? 0 : 1]
    map_public_ip_on_launch = var.assign_pub_ip

    tags = merge(
        {"Name" = "${var.project_name}-pub-${count.index}"},
        {"Tier" = "Public"},
        local.common_tags
    )
  
}

resource "aws_subnet" "private_subnets" {
    count = var.num_private_subnets

    vpc_id = aws_vpc.vpc.id
    cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + length(aws_subnet.public_subnets[*].id))
    # Just assuming 2 AZs for now
    # availability_zone = data.aws_availabilility_zones.azs.names[(var.num_public_subnets + var.num_private_subnets)%2 > 0 ? 0 : 1]
    availability_zone = data.aws_availability_zones.azs.names[count.index%2 > 0 ? 0 : 1]

    tags = merge(
        {"Name" = "${var.project_name}-priv-${count.index}"},
        {"Tier" = "Private"},
        local.common_tags
    )
  
}

##### IG and NAT
resource "aws_internet_gateway" "ig" {
    vpc_id = aws_vpc.vpc.id

    tags = local.common_tags
  
}

# Just creating 1, but ideally another for failover; need to look at multiple NATs and the route tables
resource "aws_eip" "nat_eip" {
    count = 1
    vpc = true
    tags = local.common_tags
}

resource "aws_nat_gateway" "nat" {
    count = 1
    allocation_id = aws_eip.nat_eip[count.index].id
    subnet_id = aws_subnet.public_subnets[count.index].id
    tags = local.common_tags
}

##### Routes
resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.vpc.id

    tags = merge(
        {"Name" = "${var.project_name}-public"},
        local.common_tags
    )
}

resource "aws_route" "public_route" {
    route_table_id = aws_route_table.public_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
}

resource "aws_route_table_association" "public-rt-association" {
    count = length(aws_subnet.public_subnets[*])

    subnet_id = aws_subnet.public_subnets[count.index].id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.vpc.id

    tags = merge(
        {"Name" = "${var.project_name}-private"},
        local.common_tags
    )
}

resource "aws_route_table_association" "private-rt-association" {
    count = length(aws_subnet.private_subnets[*])

    subnet_id = aws_subnet.private_subnets[count.index].id
    route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route" "private_nat_route" {
    route_table_id = aws_route_table.private_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat[0].id
  
}

##### SSH Security Group
resource "aws_security_group" "allow_ssh" {
    name = "${var.project_name}-allow-ssh"
    description = "Allow SSH access"
    vpc_id = aws_vpc.vpc.id
    
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.ssh_cidr]
    }

    # egress {
    #     from_port = 0
    #     to_port = 0
    #     protocol = "-1"
    #     cidr_blocks = ["0.0.0.0/0"]
    # }

    tags = merge(
        {"Name" = "${var.project_name}-allow-ssh"},
        local.common_tags
    )
  
}
