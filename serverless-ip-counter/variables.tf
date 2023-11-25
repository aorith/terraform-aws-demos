variable "env" {
  description = "Environment name"
  default     = "test"
}

variable "name" {
  description = "Application name"
  default     = "ip-counter"
}

variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}

locals {
  name = "${var.env}-${var.name}"
}
