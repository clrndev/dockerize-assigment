# Provider Configuration

variable "kube_config_path" {
  type    = string
  default = "~/.kube/config"
}

variable "kube_config_context" {
  type    = string
  default = "minikube"
}

# Application deploy variables

variable "app_name" {
  type    = string
  default = "dockerize"
}

variable "application_file_path" {
  type    = string
  default = "../../kubernetes/manifests/app.yaml"
}

variable "service_type" {
  type    = string
  default = "ClusterIP"

  validation {
    condition     = contains(["ClusterIP", "LoadBalancer", "NodePort"], var.service_type)
    error_message = "The service type is not valid."
  }
}

variable "desired_replicas" {
  type    = number
  default = 1
}
