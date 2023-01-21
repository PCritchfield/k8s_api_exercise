DOCKER_TAG?=latest
DOCKER_REPO?=philjim/simple-api
DOCKER_URL?=${DOCKER_REPO}:${DOCKER_TAG}
ENVFILE?=env.template
ENV=$(shell grep -v '^#' .env | xargs)
URL:=$(shell export ${ENV} && cd ./infra && pulumi stack output url)

envfile:
	cp -f $(ENVFILE) .env

deploy: pulumi_init pulumi_up

# DOCKER COMMANDS
build:
	@echo Build API Container
	docker build -t ${DOCKER_URL} .

pull:
	@echo Pull the API container from DockerHub
	docker image pull ${DOCKER_URL}

push:
	@echo Push the API container to DockerHub
	docker image push ${DOCKER_URL}

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
	export ${ENV}; \
	cd ./infra; \
	pulumi stack output kubeconfig > kubeconfig.yml; \
	KUBECONFIG=./kubeconfig.yml kubectl get all; \
	curl http://${URL}

pulumi_destroy:
	@echo Destroying the EKS Cluster...
	export ${ENV}; \
	cd ./infra && pulumi login file://../.state; \
	pulumi destroy --non-interactive --yes