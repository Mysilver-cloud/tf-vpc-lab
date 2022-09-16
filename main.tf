resource "aws_s3_bucket" "ta_backend_bucket" {
    bucket = "ta-terraform-tfstates-2965-7290-6806"

    lifecycle {
      prevent_destroy = true
    }

    tags = {
        Name = "ta-terraform-tfstates-2965-7290-6806"
        Environment = "Test"
        Team        = "Talent-Academy"
        Owner       = "Anh"
    }
}

resource "aws_s3_bucket_versioning" "version_my_bucket" {
  bucket = aws_s3_bucket.ta_backend_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_vpc" "main" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "main1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Main1"
  }
}

resource "aws_subnet" "main2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Main2"
  }
}

resource "aws_subnet" "main3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.3.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Main3"
  }
}

resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.11.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "private1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.12.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "private2"
  }
}

resource "aws_subnet" "private3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.13.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "private3"
  }
}

# create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

# create route table for IGW to enter VPC
resource "aws_route_table" "aws_route_table_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.igw.id
  }

  tags = {
    Name = "aws_route_table_public"
  }
}

# Associate public subnet 1 to route table
resource "aws_route_table_association" "rt_associate_public1" {
    subnet_id = aws_subnet.main1.id
    route_table_id = aws_route_table.aws_route_table_public.id
}

# Associate public subnet 2 to route table
resource "aws_route_table_association" "rt_associate_public2" {
    subnet_id = aws_subnet.main2.id
    route_table_id = aws_route_table.aws_route_table_public.id
}

# Associate public subnet 3 to route table
resource "aws_route_table_association" "rt_associate_public3" {
    subnet_id = aws_subnet.main3.id
    route_table_id = aws_route_table.aws_route_table_public.id
}

# Creating EIP
resource "aws_eip" "eip" {
  vpc = true
}

# Creating NAT Gateway
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.main1.id
}

# Creating Route Table for NAT Gateway
resource "aws_route_table" "rt_nat" {
    vpc_id = aws_vpc.main.id
route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.natgw.id
    }
tags = {
        Name = "Nat route for public subnet"
    }
}

# Associate private subnet 1 to route table
resource "aws_route_table_association" "rt_associate_private1" {
    subnet_id = aws_subnet.private1.id
    route_table_id = aws_route_table.rt_nat.id
}

# Associate private subnet 2 to route table
resource "aws_route_table_association" "rt_associate_private2" {
    subnet_id = aws_subnet.private2.id
    route_table_id = aws_route_table.rt_nat.id
}

# Associate private subnet 1 to route table
resource "aws_route_table_association" "rt_associate_private3" {
    subnet_id = aws_subnet.private3.id
    route_table_id = aws_route_table.rt_nat.id
}

