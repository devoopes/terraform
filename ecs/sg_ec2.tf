resource "aws_security_group" "ec2" {
  description = "Main ${var.infra_env} Ingress Security Group"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  ingress { # Postgres
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  ingress { # Redis
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]

  }
  ingress { # RabbitMQ
    from_port       = 5672
    to_port         = 5672
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  vpc_id = aws_vpc.default.id
  name   = "main-${var.infra_env}-sg-ec2"
  tags = {
    Name        = "terraform-sg-${var.infra_env}-dbs"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}
