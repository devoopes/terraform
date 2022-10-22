# ami

data "aws_ami" "default" {
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.202*-x86_64-ebs"]
  }

  most_recent = true
  owners      = ["amazon"]
}

# key_pair

resource "aws_key_pair" "default" {
  key_name   = "{var.infra_env}"
  public_key = "ssh-rsa "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINN1uHTDUFtz0KFW45uY9btgQUyTtW/RNZ01UprhqAvR sean@ulation.com"

  tags = {
    "Name" = "sean@ulation.com"
  }
}

# launch_configuration

resource "aws_launch_configuration" "default" {
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ecs.name
  image_id                    = data.aws_ami.default.id
  instance_type               = "t3.micro"
  key_name                    = "{var.infra_env}"

  lifecycle {
    create_before_destroy = true
  }

  name_prefix = "lauch-configuration-"

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  security_groups = [aws_security_group.ec2.id]
  user_data       = file("user_data.sh")
}
# autoscaling_group

resource "aws_autoscaling_group" "default" {
  desired_capacity     = 1
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.default.name
  max_size             = 2
  min_size             = 1
  name                 = "auto-scaling-group-${var.infra_env}"

  tag {
    key                 = "Env"
    propagate_at_launch = true
    value               = "var.infra_env"
  }

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = var.infra_env
  }

  target_group_arns    = [aws_alb_target_group.default.arn]
  termination_policies = ["OldestInstance"]
  vpc_zone_identifier  = [for s in data.aws_subnet.subnet_values : s.id]
}

# ecs_cluster

resource "aws_ecs_cluster" "default" {
  lifecycle {
    create_before_destroy = true
  }

  name = var.infra_env
  tags = {
    Name        = "terraform-${var.infra_env}-public-subnet"
    Role        = "public"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}

# ecr_repo

resource "aws_ecr_repository" "default" {
  name = var.infra_env
  image_scanning_configuration {
    scan_on_push = true
  }
lifecycle {
    prevent_destroy = true
  }
}
output "repository_url" {
  value = aws_ecr_repository.default.repository_url
}
