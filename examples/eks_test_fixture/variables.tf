variable "region" {
  description = "AWS Region"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
}

variable "profile" {
  description = "Which profile to use"
}

variable "vpc_name" {
  description = "Name of the VPC"
}

variable "vpc_tag" {
  description = "Tag to use in order to filter subnets"
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}"]
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = "${data.aws_vpc.main.id}"

  tags {
    Name = "${var.vpc_tag}"
  }
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = "list"
}

variable "map_accounts_count" {
  description = "The count of accounts in the map_accounts list."
  type        = "string"
  default     = 2
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type        = "list"
}

variable "map_roles_count" {
  description = "The count of roles in the map_roles list."
  type        = "string"
  default     = 1
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type        = "list"
}

variable "map_users_count" {
  description = "The count of roles in the map_users list."
  type        = "string"
  default     = 2
}
