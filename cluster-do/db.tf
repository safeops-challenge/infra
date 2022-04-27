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

  dynamic rule {
    for_each = digitalocean_kubernetes_cluster.cluster.node_pool[0].nodes
    content {
      type     = "droplet"
      value    = rule.value["droplet_id"]
    }
  }
}

resource "kubernetes_secret" "api-secret" {
  metadata {
    name      = "api"
    namespace = kubernetes_namespace.ns_app.metadata.0.name
  }
  data = {
    DB = digitalocean_database_cluster.postgres.private_uri
    PORT = 8080
    NODE_TLS_REJECT_UNAUTHORIZED = "0"
  }
}


