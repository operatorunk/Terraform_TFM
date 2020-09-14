# About
This Terraform module can be used to deploy security resources.
# Resources
1. Security groups:
    1. Bastion host sg
    1. Web instance sg
    1. DB instance sg
2. Network access control list
    1. public subnet nacl
    1. private subnet nacl

# Variables
The following variables are required for this configuration to successfully deploy all resources:

|Variable name | Description |
|--------------|-------------|
| aws_region | This variable is used to specify the region for the resources |
| aws_credentials_file | This is the file containing AWS credentials |
| aws_profile | The name of the AWS profile to use |
| project | The project name, added as a tag to resoruces (defaults to iBos) |
| environment | The environment, used to tag resources (defaults to dev) |
| bastion_cidrs | The cidrs blocks from which SSH access is allowed (office and home IPs) |
| private_subnet_cidrs | List of cidr blocks of the private subnets |
| public_subnet_cidrs | List of cidr blocks of the public subnets |
| private_subnet_ids | List of ids of the private subnets |
| public_subnet_ids | List of ids of the public subnets |
| vpc_id | The id of the VPC to deploy the security groups and nacls to |
| db_cidr_blocks | The IPs that will have access to the DB | 

# Outputs
|Output name | Description |
|------------|-------------|
| db_security_group_id | The id of the security group for DB instances |
| web_security_group_id | The id of the security group for Web instances |

# Deployment
## Prerequisites
1. Terraform installed
2. AWS IAM user and access to the Inov8 account and AWS CLI installed
3. terraform.tf file with the backend and provider configured
    1. The profile variable must be the same in both the provider block and the backend block. Backend does not allow interpolation, therefore it must be hardcoded.
eg.
```terraform
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
```
4.Variables specified (use terraform.tfvars file):
eg.
```terraform
aws_region           = "eu-west-2"
aws_credentials_file = "C:\\Users\\USER_NAME\\.aws\\credentials"
aws_profile          = "PROFILE_NAME"
project     = "PROJECT_NAME"
environment = "ENVIRONMENT_NAME"
vpc_id                = "VPC_ID"
bastion_cidrs         = ["212.22.33.44/32", "88.77.66.55/32"]
private_subnet_cidrs = ["10.0.11.0/24"]
public_subnet_cidrs  = ["10.0.1.0/24"]
private_subnet_ids   = [SUBNET_ID]
public_subnet_ids    = [SUBNET_ID]
```

## Deployment steps
1. Clone the repo
2. Redirect to the REPO\Terraform\App infrastructure\Terraform\modules\security and add the .tfvars file specifying all the required variables
3. Run `terraform init` to initialize backend (if executing for the first time) and download plugins and modules
4. Run `terraform plan -out PLAN_NAME` to create a deployment plan and what resources would be deployed. If using .tfvars with a name other than terraform.tfvars, you will have to specify -var-file=TFVARS_FILE_NAME attribute. eg. `terraform plan -out my_plan -var-file=test.tfvars`
5. Run `terraform apply PLAN_NAME` to deploy infrastructure using the plan created in the previous step
