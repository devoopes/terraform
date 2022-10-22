RDS Subnet Group

JH: Commenting out until we use this database

resource "aws_db_subnet_group" "default" {
  name       = "terraform-${var.infra_env}-db-subnetgroup"
  subnet_ids = values(aws_subnet.private)[*].id

  tags = {
    Name        = "terraform-${var.infra_env}-db-subnetgroup"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}

resource "aws_security_group" "db_instance" {
  description = "terraform-sg-${var.infra_env}-dbs"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 5432
    protocol    = "tcp"
    to_port     = 5432
  }

  name = "terraform-sg-${var.infra_env}-dbs"

  tags = {
    Name        = "terraform-sg-${var.infra_env}-dbs"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }

  vpc_id = aws_vpc.default.id
}
