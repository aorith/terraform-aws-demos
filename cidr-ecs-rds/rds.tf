resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]

  tags = local.default_tags
}

resource "aws_db_instance" "default" {
  identifier             = "${local.container_name}-db"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "15.4"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  db_name  = local.db_name
  username = data.sops_file.cidr_env.data.db_username
  password = data.sops_file.cidr_env.data.db_password

  tags = local.default_tags
}
