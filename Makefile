docker_tag = philjim/simple-api:latest
ENVFILE ?= env.template

envfile:
	cp -f $(ENVFILE) .env

build:
	@echo Build API Container
	docker build -t ${docker_tag} .
push:
	@echo Push API container to DockerHub
	docker image push ${docker_tag}

pulumi_init:
	@echo Deploy the EKS infrastructure via pulumi
	export $(grep -v '^#' .env | xargs); \
	cd ./infra && pulumi login file://../.state; \
	pulumi stack init --non-interactive --secrets-provider=passphrase --stack=dev; \
	npm install

pulumi_up:
	export $(grep -v '^#' .env | xargs); \
	cd ./infra && pulumi login file://../.state; \
	pulumi up --non-interactive --yes

pulumi_destroy:
	export $(grep -v '^#' .env | xargs); \
	cd ./infra && pulumi login file://../.state; \
	pulumi destroy --non-interactive --yes