resource "aws_security_group" "rds" {
  name   = "bedrock-rds-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Project = "karatu-2025-capstone" }
}

resource "aws_db_subnet_group" "this" {
  name       = "bedrock-db-subnets"
  subnet_ids = module.vpc.private_subnets
}

resource "random_password" "mysql" {
  length  = 16
  special = false
}
resource "random_password" "postgres" {
  length  = 16
  special = false
}

resource "aws_db_instance" "mysql" {
  identifier             = "bedrock-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "catalog"
  username               = "admin"
  password               = random_password.mysql.result
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  tags = { Project = "karatu-2025-capstone" }
}

resource "aws_db_instance" "postgres" {
  identifier             = "bedrock-postgres"
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "orders"
  username               = "dbadmin"
  password               = random_password.postgres.result
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  tags = { Project = "karatu-2025-capstone" }
}

resource "aws_secretsmanager_secret" "mysql" {
  name = "bedrock/mysql"
}
resource "aws_secretsmanager_secret_version" "mysql" {
  secret_id     = aws_secretsmanager_secret.mysql.id
  secret_string = jsonencode({ username = "admin", password = random_password.mysql.result, host = aws_db_instance.mysql.address })
}

resource "aws_secretsmanager_secret" "postgres" {
  name = "bedrock/postgres"
}
resource "aws_secretsmanager_secret_version" "postgres" {
  secret_id     = aws_secretsmanager_secret.postgres.id
  secret_string = jsonencode({ username = "admin", password = random_password.postgres.result, host = aws_db_instance.postgres.address })
}
