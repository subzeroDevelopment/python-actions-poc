locals {
  name        = "ecs-cluster"
  environment = "dev"
  region = "sa-east-1"
  image_tag = "test"
  cluster_name = "demo"

  ec2_resources_name = "${local.name}-${local.environment}"
}

data "aws_availability_zones" "available" {
  state = "available"
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name

  cidr = "10.100.0.0/16"

  azs             = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  private_subnets = ["10.100.1.0/24", "10.100.2.0/24"]
  public_subnets  = ["10.100.3.0/24", "10.100.4.0/24"]
  database_subnets = ["10.100.5.0/24", "10.100.6.0/24"] 

  enable_nat_gateway = true

  create_database_subnet_group = true

  tags = {
    Environment = local.environment
    Name        = local.name
  }
}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"

  cluster_version = "1.21"
  cluster_name    = local.cluster_name
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.private_subnets
  
  worker_groups = [
    {
      name                          = "small-pool"
      instance_type                 = "t3.small"
      asg_desired_capacity          = 3
      additional_security_group_ids = [module.security_group_db.security_group_id]
    },
  ]
}


resource "random_pet" "repo_name" {
  length = 1
}

resource "aws_ecr_repository" "ecr_repo" {
  name                 = random_pet.repo_name.id
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = local.environment
  }
}



