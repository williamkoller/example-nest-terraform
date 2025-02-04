provider "aws" {
  region = var.region
}

locals {
  tags_prod = {
    Project = "Nest Terraform"
    Environment = "Production"
  }
}

resource "aws_security_group" "new-sg" {
  vpc_id = var.vpc_id
  tags = merge(local.tags_prod, { Name = "${var.prefix}-web-sg" })

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "example_nest_terraform_instance" {
  count = 1
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = element(var.subnet_ids, count.index)
  security_groups = [aws_security_group.new-sg.id]
  associate_public_ip_address = true
  disable_api_termination = true

  root_block_device {
    volume_size = 20
  }
  tags = merge(local.tags_prod, { Name = "${var.prefix}-${var.instance_name}-${count.index}" })

}

resource "null_resource" "instance-provisioner" {
  count = length(var.subnet_ids)

  triggers = {
    instance_id      = aws_instance.example_nest_terraform_instance[count.index].id
    instance_public_ip = aws_instance.example_nest_terraform_instance[count.index].public_ip
  }

  provisioner "local-exec" {
    command = "echo ${self.triggers.instance_public_ip}"
  }
}