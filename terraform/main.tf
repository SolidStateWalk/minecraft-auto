terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az = data.aws_availability_zones.available.names[0]
}

data "aws_subnet" "target" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "availabilityZone"
    values = [local.az]
  }
}

resource "aws_security_group" "minecraft" {
  name        = "${var.project_name}-sg"
  description = "Allow Minecraft and SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Minecraft Java"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.operator_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}

resource "aws_key_pair" "minecraft" {
  key_name   = "${var.project_name}-key"
  public_key = file(var.public_key_path)

  tags = {
    Project = var.project_name
  }
}

resource "aws_ebs_volume" "minecraft_data" {
  availability_zone = local.az
  size              = var.data_volume_size_gb
  type              = "gp3"

  tags = {
    Name    = "${var.project_name}-data"
    Project = var.project_name
  }
}

resource "aws_instance" "minecraft" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.target.id
  availability_zone      = local.az
  vpc_security_group_ids = [aws_security_group.minecraft.id]
  key_name               = aws_key_pair.minecraft.key_name

  root_block_device {
    volume_size           = 12
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name    = "${var.project_name}-server"
    Project = var.project_name
  }
}

resource "aws_volume_attachment" "minecraft_data" {
  device_name  = "/dev/xvdf"
  volume_id    = aws_ebs_volume.minecraft_data.id
  instance_id  = aws_instance.minecraft.id
  force_detach = false
}

resource "aws_eip" "minecraft" {
  instance   = aws_instance.minecraft.id
  domain     = "vpc"

  tags = {
    Name    = "${var.project_name}-eip"
    Project = var.project_name
  }

  depends_on = [aws_instance.minecraft]
}
