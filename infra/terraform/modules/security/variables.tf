variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "allowed_ssh_cidrs" {
  type = list(string)
}

variable "allowed_public_http_cidrs" {
  type = list(string)
}

variable "allowed_nodeport_cidrs" {
  type = list(string)
}

variable "allowed_k8s_api_cidrs" {
  type = list(string)
}
