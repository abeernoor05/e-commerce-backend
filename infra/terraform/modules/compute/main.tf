resource "aws_key_pair" "deployer" {
  key_name   = "${var.project_name}-key"
  public_key = file(pathexpand(var.public_key_path))
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*",
      "ubuntu/images/hvm-ssd-gp3/ubuntu-jammy-22.04-amd64-server-*"
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.deployer.key_name

  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_volume_size_gb
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  lifecycle {
    precondition {
      condition     = !var.free_tier_only || contains(["t2.micro", "t3.micro"], var.instance_type)
      error_message = "free_tier_only=true requires instance_type t2.micro or t3.micro. c7i-flex.large and m7i-flex.large are not free-tier."
    }
  }

  tags = {
    Name      = "${var.project_name}-ec2"
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}
