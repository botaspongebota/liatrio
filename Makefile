account = $(shell aws sts get-caller-identity --query "Account" --output text)
region = us-east-1
rep_name = bota
lb_url = $(shell aws elb describe-load-balancers --query 'LoadBalancerDescriptions[*].[DNSName]' --output text)
###Create resourses###

vpc-eks-init-plan-apply:
	cd src && terraform init && terraform plan && terraform apply -auto-approve

build: vpc-eks-init-plan-apply
	cd docker && docker build -t app .

login: build
	aws ecr get-login-password --region $(region) | docker login --username AWS --password-stdin $(account).dkr.ecr.$(region).amazonaws.com

push: login
	docker tag app:latest $(account).dkr.ecr.$(region).amazonaws.com/$(rep_name)
	docker push $(account).dkr.ecr.$(region).amazonaws.com/$(rep_name)

update-kubeconfig: push
	aws eks update-kubeconfig --name Liatrio-Bota-cluster
	kubectl get nodes

deploy: update-kubeconfig
	cat k8s/deploy.yaml | sed "s/ACCT_NUMBER/$(account)/g;s/REGION/$(region)/g;s/REP_NAME/$(rep_name)/g" | kubectl apply -f-
	sleep 120
	curl -v http://$(lb_url)

###Destroy resourses###

destroy-kubernetes-objects:
	cd k8s && kubectl delete -f deploy.yaml
	aws ecr batch-delete-image --repository-name $(rep_name) --image-ids imageTag=latest


destroy-aws-resourses: destroy-kubernetes-objects
	cd src && terraform destroy -auto-approve

