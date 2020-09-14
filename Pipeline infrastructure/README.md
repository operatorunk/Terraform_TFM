# About
This Terraform configuration deploys resources to create infrastructure for Jenkins pipeline. The deployment process is mostly automated. EC2 instance with Jenkins installed and configured is created, and Jenkins password displayed to the user performing the deployment. This password should be saved and used to configure the admin user for Jenkins GUI. If the password has been lost, user can retrieve it by logging in to the instance and viewing the file: `/var/lib/jenkins/secrets/initialAdminPassword`.
# Resources
| Reources         | Description 
|------------------|-------------
|VPC               |Virtual private cloud
|Subnet            |The subnet where the EC2 instance will be placed.
|Internet Gateway  |Allows Internet access
|Route Table       |Used to route traffic
|Route             |Routes traffic through Internet Gateway
|Route association |Associates the route table with the subnet
|Security Group    |The security group speficies what inbound and outbound traffic is allowed. It allows SSH connection only for specified IP addresses
|Elastic IP        |Elastic IP for the Jenkins instance

# Variables
The following variables are used within the configuration:
aws_region - This variable is used to specify the region for the resources
vpc_name - This is the VPC name
vpc_cidr - This is the CIDR block for the VPC
jenkins_cidrs - These are the CIDR blocks for ssh access to the jenkins instance
jenkins_key_name - The name of a key pair used to connect to the instance
key_path - The path to the private key * Not used at the moment
project - The project for which this infrastructure will be deployed
environment - the environment for deployment

# Outputs
jenkins_eip - The IP address of the bastion host

Additionally Jenkins password is displayed to the user. This password has to be used to configure admin user in the GUI, and finish the configuration.

# Deployment
## Prerequisites
1. Terraform installed
2. AWS IAM user and access to the Inov8 account
3. Key pair in the region of deployment
4. AWS CLI installed and configured
Terraform authenticates to AWS using one of the following ways:
- Using AWS credentials specified within the code
- Using environment variables - AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY must be exported as env vars
- Using AWS credentials file
This configuration uses credential file and profile, example:
```terraform
provider "aws" {
  region                  = var.aws_region
  shared_credentials_file = var.aws_credentials_file
  profile                 = var.aws_profile
}
```
Your AWS credentials and config files should look similar to the below:
1. Credentials file
[default]
aws_access_key_id = ACCESS_KEY_ID
aws_secret_access_key = SECRET_ACCESS_KEY
[inov8]
aws_access_key_id = ACCESS_KEY_ID
aws_secret_access_key = SECRET_ACCESS_KEY
2. Config file:
[default]
region = eu-west-2
output = json
[profile inov8]
region = eu-west-2
output = json

## Deployment steps
1. Clone the repo
2. Redirect to the repo\Terraform\Pipeline infrastructure\
3. Provide required variables (use terraform.tfvars file, create if does not exist)
Example terraform.tfvafs file
```terraform
aws_region = "eu-west-2"
credentials_path = "C:\\Users\\USER_NAME\\.aws"
profile = "default"
vpc_name = "test_jenkins_vpc"
vpc_cidr = "10.0.0.0/16"
jenkins_cidrs = ["82.22.33.44/32", "55.66.77.88/32"]
jenkins_key_name = "testkey"
key_path = "C:\\Users\\USERNAME\directory\keyname.pem"
project = "project_name"
environment = "dev"
```
And update terraform.tf file with correct information in the terraform section.
Example:
```terraform
terraform {
  backend "s3" {
    encrypt = "true"
    bucket  = "test-bucket"
    key     = "jenkins/terraform.tfstate"
    region  = "eu-west-2"
    profile = "inov8"
  }
}
```
4. Run `terraform init` to initialize backend (if executing for the first time) and download plugins and modules
5. Run `terraform plan -out PLAN_NAME` to create a deployment plan and output what resources would be deployed
6. Run `terraform apply PLAN_NAME` to deploy infrastructure using the plan created in the previous step
7. Save the public IP of the jenkins instance and the displayed jenkins password