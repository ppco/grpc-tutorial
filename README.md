# personal-eks

This repository is for personal learning purposes.
Overview.
Manage AWS EKS with terraform resources, build and remove with Makefile. See below for detailed commands.

In addition, one REST API and one gRPC API are included under the src directory as samples.

## create
・create resource
```sh
$ cd terraform
$ terraform apply
```

・update for kubeconfig
```sh
$ aws eks update-kubeconfig --name sample-cluster --region ap-northeast-1
```

・push ecr repository
```sh
$ make push-rest-api
$ make push-grpc-api
```

## destroy
・destroy resoruce
```sh
$ cd terraform
$ terraform destroy
```

・AWS(aws-load-balancer-controller)
- alb
- security group
