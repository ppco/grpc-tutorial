data "aws_caller_identity" "current" {}

provider "aws" {
  region = "ap-northeast-1"
}

provider "kubectl" {
  config_path = "~/.kube/config"
  load_config_file = true
}
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}