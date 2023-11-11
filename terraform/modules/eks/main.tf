resource "kubectl_manifest" "apply" {
  yaml_body = var.yaml_body
}

