resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = "${var.project}-vpc"
    Environment = local.environment
    Terraform   = "true"
  }
}

###### INTERNET GATEWAY ######
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.project}-ig"
    Environment = local.environment
    Terraform   = "true"
  }
}

###### ROUTE TABLES AND ASSOCIATIONS ######
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name        = "${var.project}-vpc-public-rt"
    Environment = local.environment
    Terraform   = "true"
  }

}

resource "aws_route_table_association" "public" {
  count          = length(local.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.nat.id
  }

  tags = {
    Name        = "${var.project}-vpc-private-rt"
    Environment = local.environment
    Terraform   = "true"
  }

  depends_on = [aws_instance.nat]
}

resource "aws_route_table_association" "private" {
  count          = length(local.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


###### SUBNETS ######
resource "aws_subnet" "public" {
  count             = length(local.public_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "${var.project}-public-sub-${count.index}"
    Environment = local.environment
    Terraform   = "true"
  }
}

resource "aws_subnet" "private" {
  count             = length(local.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "${var.project}-private-sub-${count.index}"
    Environment = local.environment
    Terraform   = "true"
  }
}

resource "aws_db_subnet_group" "this" {
  name = "db-subnet-group"
  subnet_ids = [
    for subnet_id in aws_subnet.private.*.id :
    element(aws_subnet.private.*.id, index(aws_subnet.private.*.id, subnet_id))
  ]

  tags = {
    Name        = "${var.project}-subnet-group"
    Environment = local.environment
    Terraform   = "true"
  }
}

###### SECURITY GROUP ######
resource "aws_security_group" "nat" {
  name        = "vpc_nat"
  description = "Allow traffic to pass from the private subnet to the internet"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
      for cidr in local.private_subnet_cidrs :
      element(local.private_subnet_cidrs, index(local.private_subnet_cidrs, cidr))
    ]
  }
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      for cidr in local.private_subnet_cidrs :
      element(local.private_subnet_cidrs, index(local.private_subnet_cidrs, cidr))
    ]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project}-nat-sg"
  }
}

###### NAT INSTANCE ######
resource "aws_instance" "nat" {
  ami                         = data.aws_ami.nats.image_id
  availability_zone           = data.aws_availability_zones.available.names[0]
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.nat.id]
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true
  source_dest_check           = false
  key_name                    = var.nat_key_name

  tags = {
    Name        = "${var.project}-nat"
    Environment = local.environment
    Terraform   = "true"
  }
}