resource "kubernetes_namespace" "ns_app" {
  metadata {
    name = "app"
  }
}

resource "kubernetes_deployment" "api_deployment" {
  lifecycle {
    ignore_changes = [
      spec[0].template[0].spec[0].container[0].image
    ]
  }
  metadata {
    name      = "api"
    namespace = kubernetes_namespace.ns_app.metadata.0.name
  }
  spec {
    replicas = 5
    selector {
      match_labels = {
        app = "api"
      }
    }
    template {
      metadata {
        labels = {
          app = "api"
        }
      }
      spec {
        image_pull_secrets {
	        name = var.registry_name
        }
        container {
          image = "${digitalocean_container_registry.registry.server_url}/${var.registry_name}/api"
          name  = "api"
          port {
            container_port = 8080
          }
          env {
            name = "PORT"
            value = "8080"
          }
          env {
            name = "DB"
            value = digitalocean_database_cluster.postgres.private_uri
          }
          env {
            name = "NODE_TLS_REJECT_UNAUTHORIZED"
            value = "0"
          }

        }
      }
    }
  }
}

resource "kubernetes_service" "api_service" {
  lifecycle {
    ignore_changes = [
      metadata["annotations"]
    ]
  }
  metadata {
    name      = "api"
    namespace = kubernetes_namespace.ns_app.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.api_deployment.spec.0.template.0.metadata.0.labels.app
    }
    type = "LoadBalancer"
    port {
      port        = 8080
      target_port = 8080
    }
  }
}

resource "kubernetes_deployment" "web_deployment" {
  lifecycle {
    ignore_changes = [
      spec[0].template[0].spec[0].container[0].image
    ]
  }
  metadata {
    name      = "web"
    namespace = kubernetes_namespace.ns_app.metadata.0.name
  }
  spec {
    replicas = 5
    selector {
      match_labels = {
        app = "web"
      }
    }
    template {
      metadata {
        labels = {
          app = "web"
        }
      }
      spec {
	      image_pull_secrets {
	        name = var.registry_name
        }
        container {
          image = "${digitalocean_container_registry.registry.server_url}/${var.registry_name}/web"
          name  = "web"
          port {
            container_port = 3000
          }
          env {
            name = "PORT"
            value = "3000"
          }
          env {
            name = "API_HOST"
            value = "api.app:8080"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "web_service" {
  lifecycle {
    ignore_changes = [
      metadata["annotations"]
    ]
  }
  metadata {
    name      = "web"
    namespace = kubernetes_namespace.ns_app.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.web_deployment.spec.0.template.0.metadata.0.labels.app
    }
    type = "LoadBalancer"
    port {
      port        = 3000
      target_port = 3000
    }
  }
}
