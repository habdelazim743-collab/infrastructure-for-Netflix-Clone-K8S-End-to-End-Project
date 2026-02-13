data "aws_secretsmanager_secret" "db" {
  arn = var.db_secret_arn
}

data "aws_secretsmanager_secret_version" "db" {
  secret_id = data.aws_secretsmanager_secret.db.id
}

locals {
  db_creds_raw = jsondecode(
    data.aws_secretsmanager_secret_version.db.secret_string
  )
  db_creds = {
    engine   = "postgres"
    host     = local.db_creds_raw.KC_DB_URL_HOST
    port     = tonumber(local.db_creds_raw.KC_DB_URL_PORT)
    dbname   = local.db_creds_raw.KC_DB_URL_DATABASE
    username = local.db_creds_raw.KC_DB_USERNAME
    password = local.db_creds_raw.KC_DB_PASSWORD
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "keycloak-db-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "this" {
  identifier = "keycloak-db"

  engine         = local.db_creds.engine
  engine_version = "15"

  instance_class    = "db.m7g.large"
  allocated_storage = 20

  db_name  = local.db_creds.dbname
  username = local.db_creds.username
  password = local.db_creds.password
  port     = local.db_creds.port

  vpc_security_group_ids = [var.security_group_id]
  db_subnet_group_name  = aws_db_subnet_group.this.name
  publicly_accessible   = false

  skip_final_snapshot = true
}
