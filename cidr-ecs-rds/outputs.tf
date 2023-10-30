output "network_info" {
  value = {
    "region"          = local.region
    "vpc_cidr"        = local.vpc_cidr
    "azs"             = local.azs
    "public_subnets"  = local.public_subnets
    "private_subnets" = local.private_subnets
  }
}

output "load_balancer" {
  value = {
    "dns_name" = aws_lb.default.dns_name
  }
}
