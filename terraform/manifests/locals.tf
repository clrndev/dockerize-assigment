locals {
  namespace_name       = "app-${var.app_name}"
  application_manifest = yamldecode(file(var.application_file_path))
  service_name         = "${var.app_name}-svc"
}