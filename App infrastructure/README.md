# About
This Terraform configuration is used to deploy basic two tier infrastructure. It consists of 3 modules:
1. VPC
2. Security
3. Instances
These modules can be used separately, but all together will deploy resources required for the project to run. 
# Resources
The following resources will be deployed:
1. VPC
2. Subnets:
    1. public
    2. private
3. Subnet group
4. Internet Gateway
5. Route tables:
    1. with route from public subnet to the IG
    2. with route from the private subnet to the nat instance
6. Security groups:
    1. NAT instance sg
    2. Bastion host sg
    3. Web instance sg
    4. DB instance sg
7. Elastic IPs:
    1. EIP for bastion host
    2. EIP for web instance
8. EC2 instances:
    1. NAT instance
    2. Bastion host instance
    3. Web instance
    4. DB instance

# Variables
| Variable name | Description |
|---------------|-------------|
| aws_region - This variable is used to specify the region for the resources |
| aws_credentials_file - This is the file containing AWS credentials |
| aws_profile - The name of the AWS profile to use |
| project - The project name, added as a tag to resoruces - defaults to iBos |
| environment - The environment, used to tag resources - defaults to dev |
| vpc_name - This is the VPC name |
| vpc_cidr - This is the CIDR block for the VPC |
| nat_key_name - This is the key that will be used for the nat instance |
| web_instance_key_name | The name of a key pair used to connect to the instance |
| web_instance_key_path | The path to the private key |
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
| web_public_ip | The public IP address of the web instance(s) |
| db_address | The address of the DB instance |

# Deployment
## Prerequisites
1. Terraform installed
2. AWS IAM user and access to the Inov8 account and AWS CLI installed and configured
3. Key pairs (pem) in the region of deployment
4. terraform.tf file with the backend and provider configured
    1. The profile variable must be the same in provider block and backend block. Backend block does not allow interpolation, therefore it must be hardcoded.
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
5.Variables specified (use terraform.tfvars file):
eg.
```terraform
aws_region           = "eu-west-2"
aws_credentials_file = "C:\\Users\\USER_NAME\\.aws\\credentials"
aws_profile          = "PROFILE_NAME"
project              = "PROJECT_NAME"
environment          = "ENVIRONMENT_NAME"

# vpc module variables
vpc_name     = "VPC_NAME"
vpc_cidr     = "VPC_CIDR"
nat_key_name = "NAT_INSTANCE_KEY_NAME"

# instances module variables
web_instance_key_name   = "WEB_KEY"
web_instance_key_path   = "KEY_PATH"
db_allocated_storage    = 20
db_storage_type         = "gp2"
db_engine               = "mysql"
db_name                 = "testdb"
db_username             = "dbusertest"
db_password             = "Passw0rd!"
db_engine_version       = 5.7
db_instance_class       = "db.t2.micro"
db_parameter_group_name = "default.mysql5.7"
db_skip_final_snapshot  = true

```

## Deployment steps
1. Clone the repo
2. Redirect to the REPO\Terraform\App infrastructure\
3. Run `terraform init` to initialize backend (if executing for the first time) and download plugins and modules
4. Run `terraform plan -out PLAN_NAME` to create a deployment plan and output what resources would be deployed. If using .tfvars with a name other than terraform.tfvars, you will have to specify -var-file=TFVARS_FILE_NAME attribute. eg. `terraform plan -out my_plan -var-file=test.tfvars`
5. Run `terraform apply PLAN_NAME` to deploy infrastructure using the plan created in the previous step
