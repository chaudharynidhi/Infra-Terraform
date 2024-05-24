resource "aws_db_subnet_group" "default_private" {
  name        = "default_subnet_group"
  description = "The default subnet group for all DBs in this architecture"

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
  ]

  tags = {
    env = "Production"
  }
}

resource "aws_db_parameter_group" "log_db_parameter" {
  name   = "logs"
  family = "mysql8.0"

  parameter {
    value = "1"
    name  = "general_log"
  }

  tags = {
    env = "Production"
  }
}


resource "aws_db_instance" "db1" {
  username                = "dbWSS"
  skip_final_snapshot     = true
  publicly_accessible     = false
  password                = var.db_password
  parameter_group_name    = aws_db_parameter_group.log_db_parameter.name
  instance_class          = var.instance_class
  engine_version          = "8.0"
  db_name                 = "wordpressdb"
  engine                  = "mysql"
  db_subnet_group_name    = aws_db_subnet_group.default_private.name
  backup_retention_period = 1
  allocated_storage       = 50
  multi_az                = true

  tags = {
    env = "Production"
  }

  vpc_security_group_ids = [
    aws_security_group.sg_db.id,
  ]
}

resource "aws_security_group" "sg_db" {
  name        = "db_sg"
  description = "Default sg for the database"
  vpc_id      = aws_vpc.wordpress-vpc.id

  tags = {
    Name = "db_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id            = aws_security_group.sg_db.id
  referenced_security_group_id = aws_security_group.ec2_sg.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}

resource "aws_vpc_security_group_egress_rule" "allow_tls_eg" {
  security_group_id            = aws_security_group.sg_db.id
  referenced_security_group_id = aws_security_group.ec2_sg.id
  from_port                    = 0
  ip_protocol                  = "tcp"
  to_port                      = 65535
}

resource "aws_db_instance" "db_replica" {
  skip_final_snapshot     = true
  replicate_source_db     = aws_db_instance.db1.identifier
  publicly_accessible     = false
  parameter_group_name    = aws_db_parameter_group.log_db_parameter.name
  instance_class          = var.instance_class
  identifier              = "db-replica"
  backup_retention_period = 7
  apply_immediately       = true

  tags = {
    replica = "true"
    env     = "Production"
  }

  vpc_security_group_ids = [
    aws_security_group.sg_db.id,
  ]
}
