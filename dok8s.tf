resource "digitalocean_kubernetes_cluster" "abetest" {
  name   = "abetest"
  region = "sfo3"
  version = "1.30.4-do.0"

  node_pool {
    name       = "worker-pool"
    size       = "s-4vcpu-8gb"
    node_count = 2
    }
  
}

output "kubeconfig" { 
    value=digitalocean_kubernetes_cluster.abetest.kube_config.0.raw_config
    sensitive=true
}

output "apiserver" {
  value=digitalocean_kubernetes_cluster.abetest.kube_config.0.host
  sensitive=true
}
