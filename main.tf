module "vpc" {
  source              = "./modules/vpc"
  project_name        = var.project_name
  region              = var.region
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

module "gke" {
  source                = "./modules/gke"
  project_name          = var.project_name
  region                = var.region
  node_zone             = var.node_zone
  master_cluster_cidr   = var.master_cluster_cidr
  vpc_name              = module.vpc.vpc_name
  private_subnet_name   = module.vpc.private_subnet_name
  service_account_email = module.iam.service_account_email
  bastion_ip            = module.bastion.bastion_nat_ip
}

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
}

module "bastion" {
  source                  = "./modules/bastion"
  project_name            = var.project_name
  region                  = var.region
  node_zone               = var.node_zone
  vpc_name                = module.vpc.vpc_name
  public_subnet_name      = module.vpc.public_subnet_name
  public_subnet_self_link = module.vpc.public_subnet_self_link
}

