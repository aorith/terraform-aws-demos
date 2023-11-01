data "aws_availability_zones" "available" {}

locals {

  region = "us-east-1"
  name   = "cidr-${basename(path.cwd)}"

  vpc_cidr = "10.0.0.0/16"
  num_azs  = 2
  azs      = slice(data.aws_availability_zones.available.names, 0, local.num_azs)

  # https://developer.hashicorp.com/terraform/language/functions/cidrsubnet
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 3)]

  container_name     = "cidr-listings"
  container_image    = "ghcr.io/aorith/cidr-listings:latest"
  awslogs_group_name = "cidr-logs"
  container_port     = 8000
  db_name            = "cidr"
  db_port            = 5432

  default_tags = {
    Terraform      = "true"
    DeploymentName = local.name
  }
}
