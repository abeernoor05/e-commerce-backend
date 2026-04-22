module "network" {
  source             = "../../modules/network"
  project_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  availability_zone  = var.availability_zone
}

module "security" {
  source                    = "../../modules/security"
  project_name              = var.project_name
  vpc_id                    = module.network.vpc_id
  allowed_ssh_cidrs         = var.allowed_ssh_cidrs
  allowed_public_http_cidrs = var.allowed_public_http_cidrs
  allowed_nodeport_cidrs    = var.allowed_nodeport_cidrs
  allowed_k8s_api_cidrs     = var.allowed_k8s_api_cidrs
}

module "compute" {
  source              = "../../modules/compute"
  project_name        = var.project_name
  subnet_id           = module.network.public_subnet_id
  security_group      = module.security.app_sg_id
  instance_type       = var.instance_type
  free_tier_only      = var.free_tier_only
  root_volume_size_gb = var.root_volume_size_gb
  public_key_path     = var.public_key_path
}
