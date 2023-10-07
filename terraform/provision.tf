# kubeconfigの更新
resource "null_resource" "kubectl" {
  triggers = {
    key = aws_eks_cluster.sample_eks_cluster.name
  }

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${aws_eks_cluster.sample_eks_cluster.name} --region ap-northeast-1"
  }
}

# image build & push
resource "null_resource" "ecr_image_rest" {
  triggers = {
    key = aws_ecr_repository.rest_api.name
  }

  provisioner "local-exec" {
    command = "cd .. && make push-rest-api"
  }
}