variable "yaml_body" {
}

resource "kubectl_manifest" "apply" {
  yaml_body = var.yaml_body
}

