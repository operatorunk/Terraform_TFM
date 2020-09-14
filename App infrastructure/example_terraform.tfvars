aws_region           = "eu-west-2"
aws_credentials_file = "C:\\Users\\DawidDlubek\\.aws\\credentials"
aws_profile          = "default"

# vpc module variables
vpc_name = "test-vpc"

vpc_cidr = "10.0.0.0/16"

project = "test"

environment = "dev"

nat_key_name = "jenkins-kp"

# security module variables
bastion_cidrs         = ["212.55.11.233/32", "101.102.103.104/32", "1.3.3.7/32"]
bastion_key_name      = "bastion-key"
bastion_key_path      = "C:\\Users\\DawidDlubek\\bastion-key.pem"
db_instance_key_name  = "db-key"
db_instance_key_path  = "C:\\Users\\Dziubey\\Desktop\\Work\\db-key.pem"
web_instance_key_name = "web-key"
web_instance_key_path = "C:\\Users\\Dziubey\\Desktop\\Work\\web-key.pem"