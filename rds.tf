resource "aws_db_subnet_group" "mysql" {
  name       = "mysql"
  subnet_ids = [aws_subnet.rds_prv_sub_1a.id, aws_subnet.rds_prv_sub_1b.id]

  tags = {
    Project = "aws-poc"
  }
}

resource "aws_db_subnet_group" "mysql_replica" {
  name       = "mysql_replica"
  subnet_ids = [aws_subnet.rds_prv_sub_2a.id, aws_subnet.rds_prv_sub_2b.id]

  tags = {
    Project = "aws-poc"
  }
  provider = aws.sydney
}

resource "aws_db_instance" "mysql" {
  allocated_storage       = 5
  max_allocated_storage   = 10
  engine                  = "mysql"
  engine_version          = "5.7.36"
  instance_class          = "db.t2.micro"
  identifier              = "mydb"
  name                    = "aws"
  username                = "admin"
  password                = "password"
  parameter_group_name    = "default.mysql5.7"
  publicly_accessible     = false
  multi_az                = true
  db_subnet_group_name    = aws_db_subnet_group.mysql.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  skip_final_snapshot     = true
  backup_retention_period = 5

  tags = {
    Project = "aws-poc"
  }
}

resource "aws_db_instance" "mysql_replica" {
  replicate_source_db    = aws_db_instance.mysql.arn
  max_allocated_storage  = 10
  instance_class         = "db.t2.micro"
  identifier             = "mydb-replica"
  username               = "admin"
  password               = "password"
  parameter_group_name   = "default.mysql5.7"
  publicly_accessible    = false
  db_subnet_group_name    = aws_db_subnet_group.mysql_replica.name
  vpc_security_group_ids = [aws_security_group.rds_replica.id]
  skip_final_snapshot    = true
  tags = {
    Project = "aws-poc"
  }
  provider = aws.sydney
}
