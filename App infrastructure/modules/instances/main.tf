locals {
  environment = "${var.environment == "prod" ? "prod" : "dev"}"
}
##############################
######### INSTANCES ##########
##############################

####### ELASTIC IPs #######


resource "aws_eip" "web" {
  count    = length(var.public_subnet_cidrs)
  instance = aws_instance.web[count.index].id
  vpc      = true
}


##### WEB INSTANCE #####
resource "aws_instance" "web" {
  count                       = length(var.public_subnet_cidrs)
  ami                         = data.aws_ami.ubuntu_18.image_id
  availability_zone           = data.aws_availability_zones.available.names[count.index]
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [var.web_security_group_id]
  subnet_id                   = var.public_subnet_ids[count.index]
  associate_public_ip_address = false
  key_name                    = var.web_instance_key_name

  tags = {
    Name        = "${var.project}-web-instance-${data.aws_availability_zones.available.names[count.index]}"
    Environment = local.environment
    Terraform   = "true"
  }
}

##### DB INSTANCE(s) #####
resource "aws_db_instance" "db" {
  allocated_storage      = var.db_allocated_storage
  storage_type           = var.db_storage_type
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  name                   = var.db_name
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = var.db_parameter_group_name
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.db_security_group_id]
  skip_final_snapshot    = var.db_skip_final_snapshot

  tags = {
    Name        = "${var.project}-db-instance-${data.aws_availability_zones.available.names[0]}"
    Environment = local.environment
    Terraform   = "true"
  }
}