docker_tag = philjim/simple-api:latest
ENVFILE ?= env.template
URL=$(shell cd ./infra && pulumi stack output url)
ENV=$(shell grep -v '^#' .env | xargs)

envfile:
	cp -f $(ENVFILE) .env

build:
	@echo Build API Container
	docker build -t ${docker_tag} .
push:
	@echo Push API container to DockerHub
	docker image push ${docker_tag}

pulumi_init:
	@echo Initialize the local workspace for Pulumi
	export ${ENV}; \
	cd ./infra && pulumi login file://../.state; \
	pulumi stack init --non-interactive --secrets-provider=passphrase --stack=dev; \
	npm install

pulumi_up:
	@echo Deploy the EKS cluster and the API
	export ${ENV}; \
	cd ./infra; pulumi login file://../.state; \
	pulumi up --non-interactive --yes

pulumi_test:
	@echo Test that the EKS cluster API is responding
	cd ./infra; \
	pulumi stack output kubeconfig > kubeconfig.yml; \
	KUBECONFIG=./kubeconfig.yml kubectl get all; \
	curl http://${URL}

pulumi_destroy:
	@echo Destroying the EKS Cluster...
	export ${ENV}; \
	cd ./infra && pulumi login file://../.state; \
	pulumi destroy --non-interactive --yes