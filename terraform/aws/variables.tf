variable "project_name" {
  description = "Name of our DevOps project"
  type        = string
  default     = "devops-demo"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "lab"
}