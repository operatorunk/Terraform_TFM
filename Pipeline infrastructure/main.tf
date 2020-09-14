##############################
#### DATA SOURCE & LOCALS ####
##############################
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu_18" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  environment = "${var.environment == "prod" ? "prod" : "dev"}"
}
locals {
  public_subnet_cidrs = [cidrsubnet(var.vpc_cidr, 8, 1)]
}


##############################
#### DATA SOURCE & LOCALS ####
##############################


##############################
######### NETWORKING #########
##############################

###### VPC #######
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
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

###### SUBNETS ######
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.public_subnet_cidrs[0]
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name        = "${var.project}-jenkins-public-sub"
    Environment = local.environment
    Terraform   = "true"
  }
}

####### SECURITY GROUPS #######
resource "aws_security_group" "jenkins" {
  name        = "jenkins_sg"
  description = "Allows http access to the Jenkins instance"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      for cidr in var.jenkins_cidrs:
      element(var.jenkins_cidrs, index(var.jenkins_cidrs, cidr))
    ]
  }

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
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-jenkins-sg"
    Environment = local.environment
    Terraform   = "true"
  }
}

####### ELASTIC IPs #######
resource "aws_eip" "jenkins" {
  instance   = aws_instance.jenkins.id
  vpc        = true
  depends_on = [aws_internet_gateway.this]

  tags = {
    Name        = "${var.project}-jenkins-eip"
    Environment = local.environment
    Terraform   = "true"
  }
}

##############################
######### NETWORKING #########
##############################

########################
###### INSTANCES #######
########################
resource "aws_instance" "jenkins" {
  ami                         = data.aws_ami.ubuntu_18.image_id
  availability_zone           = data.aws_availability_zones.available.names[0]
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.jenkins.id]
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  key_name                    = var.jenkins_key_name

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install openjdk-8-jre-headless --yes",
      "sudo wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -",
      "sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'",
      "sudo apt-get update",
      "sudo apt-get install jenkins --yes",
      "echo 'JENKINS PASSWORD BELOW '",
      "sudo cat /var/lib/jenkins/secrets/initialAdminPassword",
      "echo 'JENKINS PASSWORD ABOVE'"

    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      password    = ""
      private_key = file(var.key_path)
    }
  }

  tags = {
    Name        = "${var.project}-jenkins-ec2"
    Environment = local.environment
    Terraform   = "true"
  }
}


########################
###### INSTANCES #######
########################

########################
####### OUTPUTS ########
########################

output jenkins_eip {
  value = aws_eip.jenkins.public_ip
}


########################
####### OUTPUTS ########
########################