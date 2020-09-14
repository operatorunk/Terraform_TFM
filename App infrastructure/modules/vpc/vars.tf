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

variable vpc_name {
  description = "This is the VPC name"
  type        = string
  default     = "ibos_vpc"
}

variable vpc_cidr {
  description = "This is the CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
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

variable nat_key_name {
  description = "The name of a key pair used to connect to the instance"
  type        = string
  default     = "test"
}
