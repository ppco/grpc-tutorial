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
resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
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


# node group
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.sample_eks_cluster.name
  node_group_name = "sample_node_group"
  node_role_arn   = aws_iam_role.eks_cluster_node_role.arn
  subnet_ids      = [aws_subnet.sample_private_subnet1.id, aws_subnet.sample_private_subnet2.id]
  scaling_config {
    desired_size = 4
    max_size     = 8
    min_size     = 4
  }
  instance_types = ["t3.micro"]
  depends_on     = [aws_eks_cluster.sample_eks_cluster]
}

resource "aws_iam_role" "eks_cluster_node_role" {
  name = "eks-cluster-node-managed-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_cluster_node_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_cluster_node_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_cluster_node_role.name
}

# データプレーンにFargateを利用するための設定
# resource "aws_eks_fargate_profile" "kube_system" {
#   cluster_name           = aws_eks_cluster.sample_eks_cluster.name
#   fargate_profile_name   = "fargate-profile"
#   pod_execution_role_arn = aws_iam_role.kube_system.arn
#   subnet_ids             = [aws_subnet.sample_private_subnet1.id, aws_subnet.sample_private_subnet2.id]
#   selector {
#     namespace = "kube-system"
#   }
#   selector {
#     namespace = "grpc-tutorial"
#   }
#   depends_on = [
#     aws_iam_role_policy_attachment.kube-system-AmazonEKSFargatePodExecutionRolePolicy,
#     aws_eks_cluster.sample_eks_cluster,
#   ]
# }
# resource "aws_iam_role" "kube_system" {
#   name = "eks-fargate-profile-kube-system"
#   assume_role_policy = jsonencode({
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = {
#         Service = "eks-fargate-pods.amazonaws.com"
#       }
#     }]
#     Version = "2012-10-17"
#   })
# }
# resource "aws_iam_role_policy_attachment" "kube-system-AmazonEKSFargatePodExecutionRolePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
#   role       = aws_iam_role.kube_system.name
# }

# resource "aws_eks_addon" "sample_eks_addon" {
#   cluster_name                = aws_eks_cluster.sample_eks_cluster.name
#   addon_name                  = "coredns"
#   resolve_conflicts_on_create = "OVERWRITE"
#   configuration_values = jsonencode({
#     computeType = "fargate"
#   })
# }

resource "aws_iam_policy" "AWSLoadBalancerControllerIAMPolicy" {
  name = "AWSLoadBalancerControllerIAMPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:CreateServiceLinkedRole"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = "elasticloadbalancing.amazonaws.com"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcPeeringConnections",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeTags",
          "ec2:GetCoipPoolUsage",
          "ec2:DescribeCoipPools",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeListenerCertificates",
          "elasticloadbalancing:DescribeSSLPolicies",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:DescribeTags",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cognito-idp:DescribeUserPoolClient",
          "acm:ListCertificates",
          "acm:DescribeCertificate",
          "iam:ListServerCertificates",
          "iam:GetServerCertificate",
          "waf-regional:GetWebACL",
          "waf-regional:GetWebACLForResource",
          "waf-regional:AssociateWebACL",
          "waf-regional:DisassociateWebACL",
          "wafv2:GetWebACL",
          "wafv2:GetWebACLForResource",
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL",
          "shield:GetSubscriptionState",
          "shield:DescribeProtection",
          "shield:CreateProtection",
          "shield:DeleteProtection",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateSecurityGroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateTags"
        ]
        Resource = "arn:aws:ec2:*:*:security-group/*"
        Condition = {
          StringEquals = {
            "ec2:CreateAction" = "CreateSecurityGroup"
          }
          Null = {
            "aws:RequestTag/elbv2.k8s.aws/cluster" = false
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateTags",
          "ec2:DeleteTags",
        ]
        Resource = "arn:aws:ec2:*:*:security-group/*"
        Condition = {
          Null = {
            "aws:RequestTag/elbv2.k8s.aws/cluster"  = true
            "aws:ResourceTag/elbv2.k8s.aws/cluster" = false
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:DeleteSecurityGroup",
        ]
        Resource = "*"
        Condition = {
          Null = {
            "aws:ResourceTag/elbv2.k8s.aws/cluster" = false
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateTargetGroup",
        ]
        Resource = "*"
        Condition = {
          Null = {
            "aws:RequestTag/elbv2.k8s.aws/cluster" = false
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteRule",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags",
        ]
        Resource = [
          "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*",
        ]
        Condition = {
          Null = {
            "aws:RequestTag/elbv2.k8s.aws/cluster"  = true
            "aws:ResourceTag/elbv2.k8s.aws/cluster" = false
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags",
        ]
        Resource = [
          "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*",
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:SetIpAddressType",
          "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:SetSubnets",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:DeleteTargetGroup",
        ]
        Resource = "*"
        Condition = {
          Null = {
            "aws:ResourceTag/elbv2.k8s.aws/cluster" = false
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:AddTags"
        ]
        Resource = [
          "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*",
        ]
        Condition = {
          StringEquals = {
            "elasticloadbalancing:CreateAction" = [
              "CreateTargetGroup",
              "CreateLoadBalancer"
            ]
          }
          Null = {
            "aws:RequestTag/elbv2.k8s.aws/cluster" = false
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
        ]
        Resource = "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:SetWebAcl",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:AddListenerCertificates",
          "elasticloadbalancing:RemoveListenerCertificates",
          "elasticloadbalancing:ModifyRule",
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "AmazonEKSLoadBalancerControllerRole" {
  name = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.ap-northeast-1.amazonaws.com/id/${trimprefix(aws_eks_cluster.sample_eks_cluster.identity.0.oidc.0.issuer, "https://oidc.eks.ap-northeast-1.amazonaws.com/id/")}"
      }
      Condition = {
        StringEquals = {
          "oidc.eks.ap-northeast-1.amazonaws.com/id/${trimprefix(aws_eks_cluster.sample_eks_cluster.identity.0.oidc.0.issuer, "https://oidc.eks.ap-northeast-1.amazonaws.com/id/")}:aud" = "sts.amazonaws.com"
          "oidc.eks.ap-northeast-1.amazonaws.com/id/${trimprefix(aws_eks_cluster.sample_eks_cluster.identity.0.oidc.0.issuer, "https://oidc.eks.ap-northeast-1.amazonaws.com/id/")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
    Version = "2012-10-17"
  })
  depends_on = [aws_eks_cluster.sample_eks_cluster]
}

resource "aws_iam_role_policy_attachment" "AWSLoadBalancerControllerIAMPolicy_attach" {
  role       = aws_iam_role.AmazonEKSLoadBalancerControllerRole.name
  policy_arn = aws_iam_policy.AWSLoadBalancerControllerIAMPolicy.arn
}

#https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
resource "aws_iam_openid_connect_provider" "eks_oidc" {
  url = aws_eks_cluster.sample_eks_cluster.identity.0.oidc.0.issuer

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]

  depends_on = [aws_eks_cluster.sample_eks_cluster]
}

module "aws-load-balancer-controller_ServiceAccount" {
  count  = var.update_kubeconfig
  source = "./modules/eks"
  yaml_body = templatefile("../manifests/service_account.yaml", {
    account_id = "${data.aws_caller_identity.current.account_id}"
  })
  depends_on = [aws_eks_cluster.sample_eks_cluster, null_resource.kubectl]
}

resource "helm_release" "aws-load-balancer-controller" {
  count      = var.update_kubeconfig
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  set {
    name  = "clusterName"
    value = aws_eks_cluster.sample_eks_cluster.name
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name  = "region"
    value = "ap-northeast-1"
  }
  set {
    name  = "vpcId"
    value = aws_vpc.sample_vpc.id
  }
  depends_on = [aws_eks_cluster.sample_eks_cluster, null_resource.kubectl]
}

# module "grpc_tutorial_namespace" {
#   source     = "./modules/eks"
#   yaml_body  = file("../manifests/namespace.yaml")
#   depends_on = [aws_eks_cluster.sample_eks_cluster, null_resource.kubectl]
# }

module "rest_api_deployment" {
  count  = var.update_kubeconfig
  source = "./modules/eks"
  yaml_body = templatefile("../manifests/rest-api/deployment.yaml", {
    image_uri = "${aws_ecr_repository.rest_api.repository_url}:latest"
  })
  depends_on = [aws_eks_cluster.sample_eks_cluster, null_resource.kubectl]
}

module "rest_api_service" {
  count      = var.update_kubeconfig
  source     = "./modules/eks"
  yaml_body  = file("../manifests/rest-api/service.yaml")
  depends_on = [aws_eks_cluster.sample_eks_cluster, null_resource.kubectl]
}

module "ingress" {
  count  = var.update_kubeconfig
  source = "./modules/eks"
  yaml_body = templatefile("../manifests/ingress.yaml", {
    subnet_ids = "${aws_subnet.sample_public_subnet1.id}, ${aws_subnet.sample_public_subnet2.id}"
  })
  depends_on = [aws_eks_cluster.sample_eks_cluster, null_resource.kubectl]
}