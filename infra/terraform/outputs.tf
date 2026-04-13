output "config_file_path" {
  description = "Path of the generated config file."
  value       = local_file.app_config.filename
}

output "app_name" {
  value       = var.app_name
  description = "Application name used in config."
}

output "environment" {
  value       = var.environment
  description = "Environment used in config."
}
