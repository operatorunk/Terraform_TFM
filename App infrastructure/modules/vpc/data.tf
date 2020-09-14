data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "nats" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat-2018*"]
  }
}