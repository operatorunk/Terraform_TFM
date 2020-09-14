
variable aws_region {
  description = "This variable is used to specify the region for the resources"
  type        = string
  default     = ""
}

variable aws_credentials_file {
  description = "This variable points terraform at the aws credentials file"
  type        = string
  default     = ""
}

variable aws_profile {
  description = "This variable point terraform at the aws credentials file"
  type        = string
  default     = ""
}

variable web_instance_key_name {
  description = "The name of a key pair used to connect to the instance"
  type        = string
}

variable web_instance_key_path {
  description = "The path to the private key"
  type        = string
}

variable project {
  description = "The project name"
  type        = string
  default     = "ibos"
}

variable environment {
  description = "This specifies the environment which can be either dev or test"
  type        = string
  default     = "def"
}

variable public_subnet_cidrs {
  description = "The list of public subnets cidrs"
  default     = []
}

variable private_subnet_cidrs {
  description = "The list of public subnets cidrs"
  default     = []
}

variable public_subnet_ids {
  description = "The list of public subnets ids"
  default     = []
}

variable private_subnet_ids {
  description = "The list of public subnets ids"
  default     = []
}

variable db_subnet_group_name {
  description = "The name of the subnet group used for the DB instance"
  type        = string
}

variable db_security_group_id {
  description = "The sg for the DB instance"
  type        = string
}

variable web_security_group_id {
  description = "The sg for the web instance"
  type        = string
}

variable db_allocated_storage {
  description = "The storage that is allocated to the database"
  type        = number
  default     = 20
}

variable db_storage_type {
  description = "The storage type used for the database"
  type        = string
  default     = "gp2"
}

variable db_engine {
  description = "Database Engine that is used for database instance"
  type        = string
  default     = "mysql"
}

variable db_name {
  description = "Database name"
  type        = string
  default     = "ibosdb"
}

variable db_username {
  description = "Username to access the database"
  type        = string
  default     = "ibos"
}

variable db_password {
  description = "database password"
  type        = string
  default     = "ibossupersecurepassword1"
}

variable db_engine_version {
  description = "version of the database that the database is running on"
  type        = number
  default     = 5.7
}

variable db_instance_class {
  description = "class of the instance that is run"
  type        = string
  default     = "db.t2.micro"
}

variable db_parameter_group_name {
  description = "Name of the DB parameter group to associate"
  type        = string
  default     = "default.mysql5.7"
}

variable db_skip_final_snapshot {
  description = "Boolean for skiping snapshot on terraform destroy"
  type        = bool
  default     = true
}