# grpc-tutorial

1. create resource
```sh
$ cd terraform
$ terraform apply
```

2. update for kubeconfig
```sh
$ aws eks update-kubeconfig --name sample-cluster --region ap-northeast-1
```

3. restart coredns
```sh
$ kubectl rollout restart deployments -n kube-system
```

4. push ecr repository
```sh
$ make push-rest-api ACCOUNT_ID=9999
$ make push-grpc-api ACCOUNT_ID=9999
```

5. recreate terraform
```sh
$ cd terraform
$ terraform apply
```
