output "rds_hostname" {
  description = "The address of the RDS instance"
  value       = module.database.db_instance_address
}

output "rds_port" {
  description = "The database port"
  value       = module.database.db_instance_port
}

output "rds_database_name" {
  description = "The database name"
  value       = module.database.db_instance_name
}

output "rds_username" {
  description = "The master username for the database"
  value       = module.database.db_instance_username
  sensitive   = true
}

output "rds_user_secret_arn" {
  description = "The ARN of the master user secret"
  value       = module.database.db_instance_master_user_secret_arn
}

output "rds_endpoint" {
  description = "The connection endpoint"
  value       = module.database.db_instance_endpoint
}
