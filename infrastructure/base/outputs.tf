output db_secret_name {
  value = random_pet.secret_name.id
}

output eks_cluster_endpoint {
  value = module.eks.cluster_endpoint
}
