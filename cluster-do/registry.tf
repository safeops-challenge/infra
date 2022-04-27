variable "registry_name" {}

resource "digitalocean_container_registry" "registry" {
  name                   = var.registry_name
  subscription_tier_slug = "basic"
  region                 = "nyc3"
}

resource "kubernetes_secret" "docker-registry-secret" {
  count = length(kubernetes_namespace.ns)
  metadata {
    name      = var.registry_name
    namespace = kubernetes_namespace.ns[count.index].metadata.0.name
  }
  data = {
    ".dockerconfigjson" = jsonencode({
        "auths": {
            "${digitalocean_container_registry.registry.server_url}/${var.registry_name}": {
                "username": "${var.do_token}",
                "password": "${var.registry_password}",
                "email": "${var.email}",
                "auth": base64encode("${var.do_token}:${var.registry_password}")
            }
        }
    })
  }
  type = "kubernetes.io/dockerconfigjson"
}
