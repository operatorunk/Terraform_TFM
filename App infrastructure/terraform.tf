provider "aws" {
  version                 = "~>2.0"
  region                  = var.aws_region
  shared_credentials_file = var.aws_credentials_file
  profile                 = var.aws_profile
}

terraform {
  backend "s3" {
    encrypt = "true"
    bucket  = "BUCKET_NAME"
    key     = "FOLDER/terraform.tfstate"
    region  = "REGION"
    profile = "PROFILE_NAME"
  }
}