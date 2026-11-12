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
output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app.id
}

output "ec2_public_ip" {
  description = "Public IPv4 address of the EC2 instance"
  value       = aws_instance.app.public_ip
}

output "ec2_private_ip" {
  description = "Private IPv4 address of the EC2 instance"
  value       = aws_instance.app.private_ip
}