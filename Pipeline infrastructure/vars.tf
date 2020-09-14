variable aws_region {
  description = "This variable is used to specify the region for the resources"
  type        = string
  default     = "eu-west-2"
}

variable aws_credentials_file {
  description = "This variable points terraform at the aws credentials file"
  type = string
}

variable aws_profile {
  description = "This variable point terraform at the aws credentials file"
  type = string
}

variable vpc_name {
  description = "This is the VPC name"
  type        = string
  default     = "ibos_jenkins_vpc"
}

variable vpc_cidr {
  description = "This is the CIDR block for the VPC"
  type        = string
  default     = "11.0.0.0/16"
}

variable jenkins_cidrs {
  description = "These are the cidr blocks which allow ssh access to the instance. Default values are the known used IP addresses. Should be added to terraform.tfvars file"
  type        = list
  default     = ["212.36.32.254/32", "92.40.249.79/32", "82.24.103.107/32", "161.12.46.132/32"]
}

variable "jenkins_key_name" {
  description = "The name of a key pair used to connect to the instance"
  type        = string
}

variable "key_path" {
  description = "The path to the private key"
  type        = string
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