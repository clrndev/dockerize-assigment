resource "kubernetes_namespace" "namespace" {
  metadata {
    name = local.namespace_name
  }
}

resource "kubernetes_manifest" "application" {
  manifest = merge(local.application_manifest, {
    apiVersion = local.application_manifest.apiVersion
    kind       = local.application_manifest.kind
    metadata = merge(
      local.application_manifest.metadata,
      {
        name      = var.app_name
        namespace = local.namespace_name
      }
    )
    spec = merge(
      local.application_manifest.spec,
      {
        replicas = var.desired_replicas
      }
    )
  })

  wait {
    rollout = true
  }

  depends_on = [
    kubernetes_namespace.namespace
  ]
}

resource "kubernetes_service" "service" {
  metadata {
    name      = local.service_name
    namespace = local.namespace_name
  }
  spec {
    selector = kubernetes_manifest.application.manifest.metadata.labels

    port {
      port        = 80
      target_port = 8080
    }

    type = var.service_type
  }

  depends_on = [
    kubernetes_manifest.application
  ]
}
