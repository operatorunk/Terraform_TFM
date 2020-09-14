locals {
  environment = "${var.environment == "prod" ? "prod" : "dev"}"
}
####### NACLS #######
resource "aws_network_acl" "public_subnets" {
  vpc_id = var.vpc_id
  subnet_ids = [
    for subnet_id in var.public_subnet_ids :
    element(var.public_subnet_ids, index(var.public_subnet_ids, subnet_id))
  ]

  tags = {
    Name        = "${var.project}-public-sub-acl"
    Environment = local.environment
    Terraform   = "true"
  }
}

resource "aws_network_acl_rule" "public_80_ingress" {
  network_acl_id = aws_network_acl.public_subnets.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_443_ingress" {
  network_acl_id = aws_network_acl.public_subnets.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}


resource "aws_network_acl_rule" "all_from_private_sub" {
  count          = length(var.private_subnet_cidrs)
  network_acl_id = aws_network_acl.public_subnets.id
  rule_number    = "40${count.index}"
  egress         = false
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = var.private_subnet_cidrs[count.index]
  from_port      = 0
  to_port        = 0
}



resource "aws_network_acl_rule" "public_80_egress" {
  network_acl_id = aws_network_acl.public_subnets.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_443_egress" {
  network_acl_id = aws_network_acl.public_subnets.id
  rule_number    = 200
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}



resource "aws_network_acl_rule" "all_to_private_sub" {
  count          = length(var.private_subnet_cidrs)
  network_acl_id = aws_network_acl.public_subnets.id
  rule_number    = "40${count.index}"
  egress         = true
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = var.private_subnet_cidrs[count.index]
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl" "private_subnets" {
  vpc_id = var.vpc_id
  subnet_ids = [
    for subnet_id in var.private_subnet_ids :
    element(var.private_subnet_ids, index(var.private_subnet_ids, subnet_id))
  ]

  tags = {
    Name        = "${var.project}-private-sub-acl"
    Environment = local.environment
    Terraform   = "true"
  }
}

resource "aws_network_acl_rule" "allow_all_from_pubsub" {
  count          = length(var.public_subnet_cidrs)
  network_acl_id = aws_network_acl.private_subnets.id
  rule_number    = "10${count.index}"
  egress         = false
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = var.public_subnet_cidrs[count.index]
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "allow_all_to_pubsub" {
  count          = length(var.public_subnet_cidrs)
  network_acl_id = aws_network_acl.private_subnets.id
  rule_number    = "10${count.index}"
  egress         = true
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = var.public_subnet_cidrs[count.index]
  from_port      = 0
  to_port        = 0
}

####### NACLS #######

####### SECURITY GROUPS #######

resource "aws_security_group" "web" {
  name        = "web_sg"
  description = "Defines the access to public subnet instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { # SQL Server
    from_port = 1433
    to_port   = 1433
    protocol  = "tcp"
    cidr_blocks = [
      for cidr in var.private_subnet_cidrs :
      element(var.private_subnet_cidrs, index(var.private_subnet_cidrs, cidr))
    ]
  }
  egress { # MySQL
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    cidr_blocks = [
      for cidr in var.private_subnet_cidrs :
      element(var.private_subnet_cidrs, index(var.private_subnet_cidrs, cidr))
    ]
  }

  tags = {
    Name        = "${var.project}-web-sg"
    Environment = local.environment
    Terraform   = "true"
  }

}

resource "aws_security_group" "db" {
  name        = "db_sg"
  description = "Allow incoming database connections."
  vpc_id      = var.vpc_id

  ingress { # SQL Server
    from_port       = 1433
    to_port         = 1433
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }
  ingress { # MySQL
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = [db_cidr_blocks]
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

  tags = {
    Name        = "${var.project}-db-sg"
    Environment = local.environment
    Terraform   = "true"
  }
}