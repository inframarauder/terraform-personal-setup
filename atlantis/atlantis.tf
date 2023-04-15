# fetch ubuntu LTS image
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu"]
  }
}

# fetch default VPC in region
data "aws_vpc" "default" {
  default = true
}

# create a security group for the atlantis server 
resource "aws_security_group" "atlantis" {
  name        = "atlantis-sg"
  description = "Allow SSH and port 4141"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.atlantis.id
}

resource "aws_security_group_rule" "atlantis" {
  type              = "ingress"
  from_port         = 4141
  to_port           = 4141
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.atlantis.id
}

resource "aws_security_group_rule" "all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.atlantis.id
}

# create ec2 instance 
resource "aws_instance" "atlantis" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = local.ssh_key_pair_name
  vpc_security_group_ids      = [aws_security_group.atlantis.id]
  associate_public_ip_address = true
  user_data_base64 = base64encode("${templatefile("${path.module}/atlantis-setup.sh", {
    gh_username       = var.gh_username,
    gh_pat            = var.gh_pat,
    gh_webhook_secret = var.gh_webhook_secret,
    gh_repo_allowlist = var.gh_repo_allowlist
  })}")

  tags = {
    Name      = "atlantis"
    Terraform = "true"
  }
}
