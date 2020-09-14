# About
This Terraform module can be used to deploy instances.
# Resources
1. EC2 instances:
    1. Web instance
    1. DB insntace

# Variables
The following variables are required for this configuration to successfully deploy all resources:

| Variable name | Description |
|---------------|-------------|
| aws_region | This variable is used to specify the region for the resources |
| aws_credentials_file | This is the file containing AWS credentials |
| aws_profile | The name of the AWS profile to use | 
| project | The project name, added as a tag to resoruces - defaults to iBos |
| environment | The environment, used to tag resources - defaults to dev |
| web_instance_key_name | The name of a key pair used to connect to the instance |
| web_instance_key_path | The path to the private key |
| private_subnet_cidrs | List of cidr blocks of the private subnets |
| public_subnet_cidrs | List of cidr blocks of the public subnets |
| private_subnet_ids | List of ids of the private subnets |
| public_subnet_ids | List of ids of the public subnets |
| db_subnet_group_name | The name of the subnet group for DB instance |
| db_security_group_id | Name of the security group that will be attached to the DB instance |
| web_security_group_id | Name of the security group that will be attached to web instance |
| db_allocated_storage | Storage for the DB |
| db_storage_type | Storage type (gp2 on default) |
| db_engine | The engine such as mysql, sql, etc (defaults to mysql)
| db_name | The name for the DB instance |
| db_username | The username which will be used to connect to the DB |
| db_password | The password used for connection |
| db_engine_version | Engine version (default is 5.7) |
| db_instance_class | Instance class (size) the default is db.t2.micro |
| db_parameter_group_name | Name of the DB parameter group to associate |
| db_skip_final_snapshot | Boolean for skiping snapshot on terraform destroy |

# Outputs

| Output name | Description |
|-------------|-------------|
| web_public_ip | The public ip of the web instance |
| db_address | The address of the DB instance |

# Deployment
## Prerequisites
1. Terraform installed
2. AWS IAM user and access to the Inov8 account and AWS CLI installed
3. Key pairs (pem) in the region of deployment
4. terraform.tf file with the backend and provider configured
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
5.Variables specified (use terraform.tfvars file)
eg.
```terraform
aws_region           = "eu-west-2"
aws_credentials_file = "C:\\Users\\USER_NAME\\.aws\\credentials"
aws_profile          = "PROFILE_NAME"
project              = "PROJECT_NAME"
environment          = "ENVIRONMENT_NAME"

private_subnet_cidrs = ["SUBNET_CIDR"]
public_subnet_cidrs  = ["SUBNET_CIDR"]
private_subnet_ids   = ["SUBNET_ID"]
public_subnet_ids    = ["SUBNET_ID"]

db_subnet_group_name      = "SUBNET_GROUP_NAME"
db_security_group_id      = "SG_ID"
web_security_group_id     = "SG_ID"
web_instance_key_name     = "WEB_KEY"
web_instance_key_path     = "KEY_PATH"
db_allocated_storage      = 20
db_storage_type           = "gp2"
db_engine                 = "mysql"
db_name                   = "testdb"
db_username               = "dbusertest"
db_password               = "Passw0rd!"
db_engine_version         = 5.7
db_instance_class         = "db.t2.micro"
db_parameter_group_name   = "default.mysql5.7"
db_skip_final_snapshot    = true

```
4.terraform.tf file with the backend and provider configured
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

## Deployment steps
1. Clone the repo
2. Redirect to the REPO\Terraform\App infrastructure\modules\instances
3. Run `terraform init` to initialize backend (if executing for the first time) and download plugins and modules
4. Run `terraform plan -out PLAN_NAME` to create a deployment plan and what resources would be deployed. If using .tfvars with a name other than terraform.tfvars, you will have to specify -var-file=TFVARS_FILE_NAME attribute. eg. `terraform plan -out my_plan -var-file=test.tfvars`
5. Run `terraform apply PLAN_NAME` to deploy infrastructure using the plan created in the previous step
