provider "aws" {
  region                  = var.aws_region
  shared_credentials_file = var.aws_credentials_file
  profile                 = var.aws_profile
}
# This configures the backend where the state file will be stored
terraform {
  backend "s3" {
    encrypt = "true"
    bucket  = "BUCKET_NAME"
    key     = "jenkins/terraform.tfstate"
    region  = "AWS_REGION"
    profile = "PROFILE_TO_USE"
  }
}