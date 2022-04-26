variable "do_token" {}
variable "region" {}
variable "project_name" {}
variable "min_nodes" {}
variable "max_nodes" {}
variable "machine_size" {}
variable "registry" {}
variable "registry_password" {}
variable "email" {}

provider "digitalocean" {
    token = var.do_token
}
data "digitalocean_kubernetes_versions" "versions" {}

resource "digitalocean_kubernetes_cluster" "cluster" {
    name    = var.project_name
    region  = var.region
    version = data.digitalocean_kubernetes_versions.versions.latest_version
    tags    = ["challenge", "safeops"]
    node_pool {
        name       = "worker-pool"
        size       = var.machine_size
        auto_scale = true
        min_nodes  = var.min_nodes
        max_nodes  = var.max_nodes
    }
}
provider "kubernetes" {
    host   = digitalocean_kubernetes_cluster.cluster.endpoint
    token  = digitalocean_kubernetes_cluster.cluster.kube_config[0].token
    cluster_ca_certificate = base64decode(
        digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate
    )
}

output "cluster-id" {
    value = digitalocean_kubernetes_cluster.cluster.id
}
output "endpoint" {
    value = digitalocean_kubernetes_cluster.cluster.endpoint
}
output "token" {
    value = digitalocean_kubernetes_cluster.cluster.kube_config[0].token
    sensitive = true
}

output "cert" {
    value = digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate
    sensitive = true
}

output "k8s_version" {
    value = data.digitalocean_kubernetes_versions.versions.latest_version
}
output "kube_config" {
    value = digitalocean_kubernetes_cluster.cluster.kube_config[0]
    sensitive = true
}


