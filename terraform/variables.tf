variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix for all resource names"
  type        = string
  default     = "minecraft-auto"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "public_key_path" {
  description = "Path to SSH public key"
  type        = string
}

variable "operator_ip_cidr" {
  description = "CIDR for SSH access"
  type        = string
}

variable "data_volume_size_gb" {
  description = "EBS data volume size in GB"
  type        = number
  default     = 10
}
