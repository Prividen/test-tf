terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "prividen-test-org"

    workspaces {
      prefix = "tfc-"
    }
  }
}


provider "aws" {
  region = "us-west-2"
}

variable "TFC_WORKSPACE_NAME" {
  type = string
  default = ""
}

locals {
  ws = var.TFC_WORKSPACE_NAME != "" ?  trimprefix("${var.TFC_WORKSPACE_NAME}", "tfc-") : "${terraform.workspace}"

  inst_type_ws_map = {
    stage = "t2.micro"
    prod = "t3.micro"
  }

  t1_count_ws_map = {
    "stage" = 1
    "prod" = 2
  }

  t2_ws_map = {
    stage = toset( ["North"] )
    prod = toset( ["East", "West", "South", "North"] )
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name = "owner-alias"
    values = ["amazon"]
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_security_group" "ssh_enabled" {
  name = "launch-wizard-1"
}

resource "aws_instance" "test1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.inst_type_ws_map["${local.ws}"]
  key_name = "mk-rsa"
  vpc_security_group_ids = [ data.aws_security_group.ssh_enabled.id ]

  count = "${lookup(local.t1_count_ws_map, local.ws)}"

  tags = {
    Name = "TestInstance1"
    Project = "Netology"
  }
}

resource "aws_instance" "test2" {
  for_each = local.t2_ws_map["${local.ws}"]
  ami = data.aws_ami.amazon_linux.id
  instance_type = local.inst_type_ws_map["${local.ws}"]
  key_name = "mk-rsa"
  vpc_security_group_ids = [ data.aws_security_group.ssh_enabled.id ]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "TestInstance2"
    Project = "Netology"
    Region = each.key
  }
}


//resource "aws_network_interface_sg_attachment" "t1_ssh" {
//  security_group_id    = "${data.aws_security_group.ssh_enabled.id}"
//  network_interface_id = "${aws_instance.test1[count.index].primary_network_interface_id}"
//}
//
//resource "aws_network_interface_sg_attachment" "t2_ssh" {
//  security_group_id    = "${data.aws_security_group.ssh_enabled.id}"
//  network_interface_id = ["${aws_instance.test2.*.primary_network_interface_id}"]
//}
