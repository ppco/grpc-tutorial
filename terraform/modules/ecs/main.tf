resource "aws_ecr_repository" "sample_ecr_repo" {
  name = "grpc-tutorial"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

