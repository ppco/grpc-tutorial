# grpc-tutorial

update for connection
```sh
 aws eks update-kubeconfig --name sample-cluster --region ap-northeast-1
```

クラスタ起動後のcoredns再起動
```
kubectl rollout restart deployments -n kube-system
```

