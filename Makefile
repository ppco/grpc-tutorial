include .env
eks-init:
	export AWS_PROFILE=${AWS_PROFILE} && \
	cd terraform && \
	terraform init && \
	terraform apply -auto-approve && \
	terraform apply -auto-approve -var="update_kubeconfig=1"

include .env
eks-destroy:
	@echo "コンソールからALBとSGを削除してください"
	export AWS_PROFILE=${AWS_PROFILE} && \
	cd terraform && \
	terraform destroy

tf-fmt:
	@terraform fmt -recursive

include .env
push-rest-api:
	aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com
	docker build -f src/rest_sample/Dockerfile -t rest_api .
	docker tag rest_api:latest ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/rest_api:latest
	docker push ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/rest_api:latest

include .env
push-grpc-api:
	aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com
	docker build -f src/grpc_sample/Dockerfile -t grpc_api .
	docker tag grpc_api:latest ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/grpc_api:latest
	docker push ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/grpc_api:latest