# personal-eks

This repository is for personal learning purposes.

## Overview.

Manage AWS EKS with terraform resources, build and remove with Makefile. See below for detailed commands.

In addition, one REST API and one gRPC API are included under the src directory as samples.

# set up
Set the following environment variables in the `.env` file before creating and deleting resources
```.env
ACCOUNT_ID=
AWS_PROFILE=
```

## create
```sh
$ make eks-init
```

## destroy
```sh
$ make eks-destroy
```

Before executing the command, remove the following resources that are attached to k8s. Otherwise, you will not be able to delete the internet gateway and the subnet.
- ALB
- TargetGroup
- SecurityGroup

This operation will no longer be necessary as the manifest changes in the future.
