resource "kubernetes_namespace" "ns_app" {
  metadata {
    name = "app"
  }
}