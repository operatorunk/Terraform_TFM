locals {
  environment = "${var.environment == "prod" ? "prod" : "dev"}"
}

module "vpc" {
  source       = "./\\modules\\vpc"
  vpc_name     = var.vpc_name
  vpc_cidr     = var.vpc_cidr
  project      = var.project
  environment  = local.environment
  nat_key_name = var.nat_key_name
}

module "security" {
  vpc_id               = module.vpc.vpc_id
  source               = "./\\modules\\security"
  private_subnet_cidrs = module.vpc.private_sub_cidrs
  public_subnet_cidrs  = module.vpc.public_sub_cidrs
  private_subnet_ids   = module.vpc.private_sub_ids
  public_subnet_ids    = module.vpc.public_sub_ids
  project              = var.project
  environment          = local.environment
}

module instances {
  source                    = "./\\modules\\instances"
  web_instance_key_name     = var.web_instance_key_name
  web_instance_key_path     = var.web_instance_key_path
  project                   = var.project
  environment               = local.environment
  public_subnet_cidrs       = module.vpc.public_sub_cidrs
  private_subnet_cidrs      = module.vpc.private_sub_cidrs
  public_subnet_ids         = module.vpc.public_sub_ids
  private_subnet_ids        = module.vpc.private_sub_ids
  db_subnet_group_name      = module.vpc.subnet_group_name
  db_security_group_id      = module.security.db_security_group_id
  web_security_group_id     = module.security.web_security_group_id
  db_allocated_storage    = var.db_allocated_storage
  db_storage_type         = var.db_storage_type
  db_engine               = var.db_engine
  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = var.db_password
  db_engine_version       = var.db_engine_version
  db_instance_class       = var.db_instance_class
  db_parameter_group_name = var.db_parameter_group_name
  db_skip_final_snapshot  = var.db_skip_final_snapshot
}
