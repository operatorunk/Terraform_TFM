
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

variable private_subnet_cidrs {
  description = "List of private subnet CIDR blocks"
  default     = []
}

variable public_subnet_cidrs {
  description = "List of public subnet CIDR blocks"
  default     = []
}

variable private_subnet_ids {
  description = "List of private subnet ids"
  default     = []
}

variable public_subnet_ids {
  description = "List of public subnet ids"
  default     = []
}

variable "project" {
  description = "The project name"
  type        = string
  default     = "ibos"
}

variable environment {
  description = "This specifies the environment which can be either dev or test"
  type        = string
  default     = "dev"
}

variable vpc_id {
  description = "This is the vpc id"
  type        = string
}

variable db_cidr_blocks {
  description = "The IPs that will have access to the DB"
  default = []
}



