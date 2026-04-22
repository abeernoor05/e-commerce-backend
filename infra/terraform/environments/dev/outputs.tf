output "instance_public_ip" {
  description = "Public IP of the app server"
  value       = module.compute.instance_public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the app server"
  value       = module.compute.instance_public_dns
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = module.compute.instance_id
}

output "key_pair_name" {
  description = "AWS key pair name used by the EC2 instance"
  value       = module.compute.key_pair_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = module.network.public_subnet_id
}

output "public_subnet_az" {
  description = "Availability zone used for the public subnet"
  value       = module.network.public_subnet_az
}

output "security_group_id" {
  description = "Security group attached to the EC2 instance"
  value       = module.security.app_sg_id
}
