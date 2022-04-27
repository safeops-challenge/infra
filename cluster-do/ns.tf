locals {
  ns_list = ["dev", "prod"]
}

resource "kubernetes_namespace" "ns" {
  count = length(local.ns_list)
  metadata {
    name = local.ns_list[count.index]
  }
}