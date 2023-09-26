# EKSクラスター関連
resource "aws_eks_cluster" "sample_eks_cluster" {
  name     = "sample-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  vpc_config {
    subnet_ids = [aws_subnet.sample_private_subnet1.id, aws_subnet.sample_private_subnet2.id]
  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
  ]
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-execution-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}
# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${aws_eks_cluster.sample_eks_cluster.name}/cluster"
  retention_in_days = 3
}


# データプレーンにFargateを利用するための設定
resource "aws_eks_fargate_profile" "kube_system" {
  cluster_name           = aws_eks_cluster.sample_eks_cluster.name
  fargate_profile_name   = "fargate-profile"
  pod_execution_role_arn = aws_iam_role.kube_system.arn
  subnet_ids             = [aws_subnet.sample_private_subnet1.id, aws_subnet.sample_private_subnet2.id]
  selector {
    namespace = "kube-system"
  }
  selector {
    namespace = "grpc-tutorial"
  }
  depends_on = [
    aws_iam_role_policy_attachment.kube-system-AmazonEKSFargatePodExecutionRolePolicy,
    aws_eks_cluster.sample_eks_cluster,
  ]
}
resource "aws_iam_role" "kube_system" {
  name = "eks-fargate-profile-kube-system"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}
resource "aws_iam_role_policy_attachment" "kube-system-AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.kube_system.name
}

resource "aws_eks_addon" "sample_eks_addon" {
  cluster_name                = aws_eks_cluster.sample_eks_cluster.name
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"
  configuration_values = jsonencode({
    computeType = "fargate"
  })
}