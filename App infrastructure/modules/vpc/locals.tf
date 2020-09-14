locals {
  private_subnet_cidrs = [cidrsubnet(var.vpc_cidr, 8, 1), cidrsubnet(var.vpc_cidr, 8, 2)]
}
locals {
  public_subnet_cidrs = [cidrsubnet(var.vpc_cidr, 8, 11)]
}
locals {
  environment = "${var.environment == "prod" ? "prod" : "dev"}"
}