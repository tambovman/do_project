output "project_name" {
  description = "Name of the project"
  value       = var.project_name
}

output "environment" {
  description = "Deployment environment"
  value       = var.environment
}

output "resource_prefix" {
  description = "Prefix for naming AWS resources"
  value       = "${var.project_name}-${var.environment}"
}