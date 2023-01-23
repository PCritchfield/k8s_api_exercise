DOCKER_TAG?=latest
DOCKER_REPO?=philjim/simple-api
DOCKER_URL?=${DOCKER_REPO}:${DOCKER_TAG}
ENVFILE?=env.template
ENV=$(shell grep -v '^#' .env | xargs)
URL:=$(shell export ${ENV} && cd ./infra && pulumi stack output url)

help: 
	@printf "\033[33mUsage:\033[0m\n  make [target] [arg=\"val\"...]\n\n\033[33mTargets:\033[0m\n"
	@grep -E '^[-a-zA-Z0-9_\.\/]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[32m%-15s\033[0m %s\n", $$1, $$2}'

deploy: pulumi_init pulumi_up ## Run both pulumi up and pulumi init

.PHONY: envfile
envfile: ## Create a .env file from env.template
	@cp -f $(ENVFILE) .env

.PHONY: build
build: ## Build the Express JS API Container
	@docker build -t ${DOCKER_URL} .

.PHONY: pull
pull: ## Pull the Express JS API Container from the container registry
	@docker image pull ${DOCKER_URL}

.PHONY: push
push: ## Push the Express JS API Container to the container registry
	@docker image push ${DOCKER_URL}

.PHONY: pulumi_init
pulumi_init: ## Initialize the local environment for deployment
	@export ${ENV}; \
	cd ./infra && pulumi login file://../.state; \
	pulumi stack init --non-interactive --secrets-provider=passphrase --stack=dev; \
	npm install

.PHONY: pulumi_up
pulumi_up: ## Deploy the EKS cluster and API to AWS
	export ${ENV}; \
	cd ./infra; pulumi login file://../.state; \
	pulumi up -s dev --non-interactive --yes

.PHONY: pulumi_test
pulumi_test: ## Confirm that the EKS cluster is up and running
	@export ${ENV}; \
	cd ./infra; \
	pulumi stack output kubeconfig > kubeconfig.yml; \
	KUBECONFIG=./kubeconfig.yml kubectl get all; \
	curl http://${URL}

.PHONY: pulumi_destroy
pulumi_destroy: ## Destroy the EKS Cluster
	@export ${ENV}; \
	cd ./infra && pulumi login file://../.state; \
	pulumi destroy -s dev --non-interactive --yes