terraform {
  required_version = "~> 1.5.7"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~>1.14.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.19.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~>2.11.0"
    }
  }
}