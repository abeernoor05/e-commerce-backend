variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "cc-project03"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Optional AZ for the public subnet (leave null to auto-select first available)"
  type        = string
  default     = null
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH into EC2"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_public_http_cidrs" {
  description = "CIDR blocks allowed to access HTTP/HTTPS on the node"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_nodeport_cidrs" {
  description = "CIDR blocks allowed to access Kubernetes NodePort range"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_k8s_api_cidrs" {
  description = "CIDR blocks allowed to access Kubernetes API (6443)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_type" {
  description = "EC2 instance type (recommended for this project: m7i-flex.large; alternative: c7i-flex.large)"
  type        = string
  default     = "m7i-flex.large"

  validation {
    condition = contains([
      "t2.micro",
      "t3.micro",
      "c7i-flex.large",
      "m7i-flex.large"
    ], var.instance_type)
    error_message = "instance_type must be one of: t2.micro, t3.micro, c7i-flex.large, m7i-flex.large."
  }
}

variable "free_tier_only" {
  description = "When true, only free-tier-safe instance types are allowed"
  type        = bool
  default     = false
}

variable "root_volume_size_gb" {
  description = "EC2 root EBS size in GB"
  type        = number
  default     = 30

  validation {
    condition     = var.root_volume_size_gb >= 20 && var.root_volume_size_gb <= 100
    error_message = "root_volume_size_gb must be between 20 and 100 GB for this project profile."
  }
}

variable "public_key_path" {
  description = "Path to public SSH key"
  type        = string
}
