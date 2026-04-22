variable "project_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "free_tier_only" {
  type = bool
}

variable "root_volume_size_gb" {
  type = number
}

variable "public_key_path" {
  type = string
}
