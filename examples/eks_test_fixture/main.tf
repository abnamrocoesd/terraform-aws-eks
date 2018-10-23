terraform {
  required_version = "= 0.11.8"
}

provider "aws" {
  version = ">= 1.24.0"
  region  = "${var.region}"
  profile = "${var.profile}"
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "${var.cluster_name}"

  worker_groups = [
    {
      instance_type       = "t2.large"
      additional_userdata = "echo foo bar"
      subnets             = "${join(",", data.aws_subnet_ids.private.ids)}"
    },
    {
      instance_type                 = "t2.large"
      additional_userdata           = "echo foo bar"
      subnets                       = "${join(",", data.aws_subnet_ids.private.ids)}"
      additional_security_group_ids = "${aws_security_group.worker_group_mgmt_one.id},${aws_security_group.worker_group_mgmt_two.id}"
    },
  ]

  tags = {
    Environment = "test"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
    Workspace   = "${terraform.workspace}"
  }
}

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  description = "SG to be applied to all *nix machines"
  vpc_id      = "${data.aws_vpc.main.id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id      = "${data.aws_vpc.main.id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = "${data.aws_vpc.main.id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

module "eks" {
  source                               = "../.."
  cluster_name                         = "${local.cluster_name}"
  subnets                              = "${data.aws_subnet_ids.private.ids}"
  tags                                 = "${local.tags}"
  vpc_id                               = "${data.aws_vpc.main.id}"
  worker_groups                        = "${local.worker_groups}"
  worker_group_count                   = "2"
  worker_additional_security_group_ids = ["${aws_security_group.all_worker_mgmt.id}"]
  map_roles                            = "${var.map_roles}"
  map_users                            = "${var.map_users}"
  map_accounts                         = "${var.map_accounts}"
}
