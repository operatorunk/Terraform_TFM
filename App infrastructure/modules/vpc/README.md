# About
This Terraform module can be used to deploy networking resources.
# Resources
1. VPC
2. Subnets:
    1. public
    2. private
3. Subnet group
4. Internet Gateway
5. Route tables:
    1. with route from public subnet to the IG
    1. with route from the private subnet to the nat instance
6. Security groups:
    1. NAT instance sg
7. EC2 instances:
    1. NAT instance

# Variables
The following variables are required for this configuration to successfully deploy all resources:

| Variable name | Description |
|---------------|-------------|
| aws_region | This variable is used to specify the region for the resources |
| aws_credentials_file | This is the file containing AWS credentials |
| aws_profile | The name of the AWS profile to use |
| project | The project name, added as a tag to resoruces (defaults to ibos) |
| environment | The environment, used to tag resources (defaults to dev) |
| vpc_name | This is the VPC name |
| vpc_cidr | This is the CIDR block for the VPC |
| nat_key_name | This is the key that will be used for the nat instance |

# Outputs

| Output name | Description |
|-------------|-------------|
| private_sub_ids | This will output the private subnet ids |
| public_sub_ids | This will output the public subnet ids |
| private_sub_cidrs | This will output the private subnet cidrs |
| public_sub_cidrs | This will output the public subnet cidrs |
| subnet_group_name | This will output the subnet group name |
| vpc_id | This will output the vpc id |

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
project = "PROJECT_NAME"
environment = "ENVIRONMENT_NAME"

vpc_name = "VPC_NAME"
vpc_cidr = "VPC_CIDR"
nat_key_name = "NAT_INSTANCE_KEY_NAME"
```

## Deployment steps
1. Clone the repo
2. Redirect to the REPO\Terraform\App infrastructure\Terraform\modules\vpc
3. Run `terraform init` to initialize backend (if executing for the first time) and download plugins and modules
4. Run `terraform plan -out PLAN_NAME` to create a deployment plan and what resources would be deployed. If using .tfvars with a name other than terraform.tfvars, you will have to specify -var-file=TFVARS_FILE_NAME attribute. eg. `terraform plan -out my_plan -var-file=test.tfvars`
5. Run `terraform apply PLAN_NAME` to deploy infrastructure using the plan created in the previous step
