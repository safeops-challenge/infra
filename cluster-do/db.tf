resource "digitalocean_database_cluster" "postgres" {
  name       = "postgres-cluster"
  engine     = "pg"
  version    = "11"
  size       = "db-s-1vcpu-1gb"
  region     = "nyc1"
  node_count = 1
}

resource "digitalocean_database_firewall" "cluster-fw" {
  cluster_id = digitalocean_database_cluster.postgres.id

  rule {
    type  = "k8s"
    value = digitalocean_kubernetes_cluster.cluster.id
  }
}

  resource "kubernetes_secret" "api-secret" {
    count = length(kubernetes_namespace.ns)
    metadata {
      name      = "api"
      namespace = kubernetes_namespace.ns[count.index].metadata.0.name
    }
    data = {
      DB = digitalocean_database_cluster.postgres.private_uri
      PORT = 8080
      NODE_TLS_REJECT_UNAUTHORIZED = "0"
    }
  }


