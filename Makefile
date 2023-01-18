docker_tag = philjim/simple-api:latest

build:
	@echo Build API Container
	docker build -t ${docker_tag} .
push:
	@echo Push API container to DockerHub
	docker image push ${docker_tag}

pull_infra:
	@echo Pull the Pulumi container
	docker pull pulumi/pulumi-nodejs:3.51.1