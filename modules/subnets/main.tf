
# Internet Gateway
# Internet Gateway allows the VPC to communicate with the internet
# It is required for public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "main-igw"
  }
}
# Public Subnet
# This subnet is public because:
# - map_public_ip_on_launch = true
# - It will be associated with a route table that has a route to the IGW
#resource "aws_subnet" "public" {
# for_each = {for idx, cidr in var.public_subnet_cidr : idx => cidr }
# vpc_id                  = var.vpc_id
# cidr_block              = each.value
# availability_zone       = var.azs[each.key % length(var.azs)]          # First Availability Zone
#map_public_ip_on_launch = true                # Instances get a public IP
#
#tags = {
#  Name = "public-subnet-${each.key + 1}"
# }
#}
resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidr)
  vpc_id            = var.vpc_id
  cidr_block        = var.public_subnet_cidr[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}


# Elastic IP
# A static public IP address for the NAT Gateway
# Must be created in the VPC domain
resource "aws_eip" "nat" {
  domain = "vpc"
}
# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id # Attach the Elastic IP
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "nat-gateway"
  }

  # Ensure the Internet Gateway exists before creating NAT
  depends_on = [aws_internet_gateway.igw]
}
# Private Subnets
# ===============
# Create multiple private subnets using count
# These subnets do NOT assign public IPs
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}
# Public Route Table
# ==================
# Routes all outbound traffic to the Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0" # All internet traffic
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associate the public subnet with the public route table
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
# Private Route Table
# ===================
# Routes outbound traffic from private subnets to the NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0" # All internet traffic
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

# Associate all private subnets with the private route table
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

