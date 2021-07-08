packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_access_key" {
  type    = string
  default = ""
  sensitive = true
}
variable "aws_secret_key" {
  type    = string
  default = ""
  sensitive = true
}

variable "ami_prefix" {
  type    = string
  default = "packer-linux-aws-redis"
}

source "amazon-ebs" "linux" {
  access_key    = "${var.aws_access_key}"
  secret_key    = "${var.aws_secret_key}"
  ami_name      = "${var.ami_prefix}-${formatdate("YYYYMMDDhhmm", timestamp())}"
  instance_type = "t2.micro"
  region        = "ap-northeast-1"

  //  assume_role {
  //    role_arn     = "arn:aws:iam::766486742765:role/ROLE_NAME"
  //    session_name = "packer"
  //    external_id  = "EXTERNAL_ID"
  //  }
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["137112412989"]
  }
  ssh_username = "ec2-user"
}

build {
  sources = [
    "source.amazon-ebs.linux"
  ]
  provisioner "shell" {
    environment_vars = [
      "FOO=hello world",
    ]
    inline = [
      "echo Installing Redis and nginx",
      "sleep 30",
      "sudo yum update -y",
      "sudo yum install -y redis-server",
      "echo \"FOO is $FOO\" > example.txt",
      "sudo yum install -y nginx",
    ]
  }

  provisioner "shell" {
    inline = ["echo This provisioner runs last"]
  }
}
