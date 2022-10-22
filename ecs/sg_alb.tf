resource "aws_security_group" "alb" {
  description = "terraform-${var.infra_env}-alb"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = [var.vpc_cidr]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  name = "terraform-${var.infra_env}-alb"

  tags = {
    Name        = "terraform-${var.infra_env}-alb"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }

  vpc_id = aws_vpc.default.id
}
