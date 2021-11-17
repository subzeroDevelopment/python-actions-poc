locals {
  db_name = "parrot"
  db_port = 5432
}

resource "random_pet" "username" {
  length = 1
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

module "security_group_db" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.4.0"

  name   = "db-sg"
  vpc_id = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "postgresql-tcp"
      source_security_group_id = module.eks.worker_security_group_id
    }
  ]

  ingress_with_self = [
    {
      rule = "all-all"
    }
  ]

  egress_cidr_blocks = ["0.0.0.0/0"]
}


resource "random_pet" "secret_name" {
  length = 1
}

resource "aws_secretsmanager_secret" "parrot_db_secret" {
  name = random_pet.secret_name.id
}


resource "aws_secretsmanager_secret_version" "parrot_db_secret_version" {
  secret_id = aws_secretsmanager_secret.parrot_db_secret.id
  secret_string = jsonencode({
    POSTGRES_DB       = module.db.db_instance_name
    POSTGRES_USER     = module.db.db_instance_username
    POSTGRES_PASSWORD = module.db.db_master_password
    POSTGRES_HOST     = split(":",module.db.db_instance_endpoint)[0]
    POSTGRES_PORT     = module.db.db_instance_port
    APP_VERSION       = "0.1.0"
  })
}



module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "3.4.1"

  identifier = local.db_name

  engine               = "postgres"
  engine_version       = "11.10"
  family               = "postgres11" # DB parameter group
  major_engine_version = "11"         # DB option group
  instance_class       = "db.t3.micro"

  allocated_storage     = 5
  max_allocated_storage = 10
  storage_encrypted     = false

  name     = local.db_name
  username = random_pet.username.id
  password = random_password.password.result
  port     = local.db_port

  multi_az               = false
  subnet_ids             = module.vpc.database_subnets
  vpc_security_group_ids = [module.security_group_db.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = false
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "parrot-monitoring-role-name"
  monitoring_role_description           = "Description for monitoring role"

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  tags = {
    Environment = local.environment
  }
  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
  db_subnet_group_tags = {
    "Sensitive" = "high"
  }
}
