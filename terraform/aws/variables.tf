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
variable "vpc_cidr" {
  description = "IPv4 CIDR block for the DevOps lab VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "IPv4 CIDR block for the public subnet"
  type        = string
  default     = "10.20.1.0/24"
}
variable "ssh_allowed_cidr" {
  description = "Public IPv4 CIDR allowed to SSH into EC2"
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0)) && endswith(var.ssh_allowed_cidr, "/32")
    error_message = "Provide one public IPv4 address in /32 CIDR format."
  }
}