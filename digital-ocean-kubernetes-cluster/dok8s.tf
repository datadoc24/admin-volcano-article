resource "digitalocean_kubernetes_cluster" "mycluster" {
  name   = "mycluster"
  region = "tor1"
  version = "1.31.1-do.4"

  node_pool {
    name       = "worker-pool"
    size       = "s-4vcpu-8gb"
    node_count = 2
    }
  
}

#resource "digitalocean_kubernetes_node_pool" "mygpupool" {
#  cluster_id = digitalocean_kubernetes_cluster.abetest.id
#
#  name       = "gpu-pool"
#  size       = "gpu-h100x1-80gb"
#  node_count = 2
#  tags       = ["mygpupool"]
#}

output "clusterid" {
  value=digitalocean_kubernetes_cluster.mycluster.id
}

output "kubeconfig" { 
    value=digitalocean_kubernetes_cluster.mycluster.kube_config.0.raw_config
    sensitive=true
}

output "apiserver" {
  value=digitalocean_kubernetes_cluster.mycluster.kube_config.0.host
  sensitive=true
}
