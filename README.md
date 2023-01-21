# Express.js API in EKS
## The Basics
### About this project<hr>
This is a sample project to demonstrate a number of key concepts.
1. How to create and containerize a sample Express.js API
2. How to use a Makefile as a development and deployment control plane
3. How to deploy an EKS cluster and related infrastructure to AWS using Pulumi
4. How to deploy the API container to the newly created EKS cluster
5. How to confirm that the cluster and the API are both working


### Infrastructure <hr>
This project uses Pulumi, in javascript, to automate the deployment of the infrastructure and maintain state.  
This code will deploy a new VPC and all related network assets to AWS, as well as the EKS cluster.  
The EKS cluster consists of 3 nodes in 3 private subnets spread across 3 availability zones.
Lastly there is a public facing load balancer that provides for incoming traffic.
<br/><br/>
``` mermaid
C4Context
    title EKS architectural Diagram
```

<br/>

## Getting Started 
### Prerequisites <hr>
The following utilities and applications are required prior to work with this repository.
- GNU Make - Required to utilize the Makefile and acts as our control plane
- [Docker](https://docs.docker.com/get-docker/) - Used for the development and containerization of the Express.js API
- [Pulumi](https://www.pulumi.com/docs/get-started/aws/begin/) - This is required to run the automation and Infrastructure as Code
- [awscli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) - This is required by Pulumi to interact with AWS
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl) - This will be used to interact with the cluster once it is deployed.
<hr>

### Setting you environment Variables <hr>
1. From the root of the project run the command `make envfile`.
    - This will create your .env file base on the env.template.
2. Now edit the newly create .env file to allow for Pulumi to run against AWS.


## Deploy the infrastructure and API
### The quick way
A single command to get your environment up and running.
- From the root directory run the command `make deploy`.
This will run the make commands `pulumi_init` and `pulumi_deploy` describe in detail below.
<hr>

### The "slow" way
#### make pulumi_init <hr>
-  From the root of the project run the command `make pulumi_init`. This will do a few things;
    1. Configures Pulumi to use the local `.state/` directory for state management.
    2. Initialize the working stack "dev".
    3. Runs `npm install` to install the required node assets.

#### make pulumi_up<hr>
- From the root of the project run the command `make pulumi_init`
    1. This will log you into the local state at `.state/`.
    2. Run `pulumi up` in a non-interactive fashion to create the infrastructure, cluster, and deploy the API defined in the `infra/` directory.
        - This takes about 15 minutes and will return a kubeconfig and the URL of the cluster load balancer.
<hr>

## Other Commands
### Docker Related Commands<hr>
If you want to locally build or work with the Express API these commands will help with that.  
These commands all run against the Dockerfile found in the root of the project.<p> 

With any of these commands you can change how the container is tagged or what dockerhub repository is used by passing the variables in at command execution.  
EXAMPLES:  
`DOCKER_TAG=v1 make build`  
`DOCKER_REPO=philjim/awesome-api make build`  
`DOCKER_URL=philjim/awesome-api:v2 make build`  <hr>

#### `make build`
    Runs the command `docker build -t ${DOCKER_URL}`
#### `make pull`
    Runs the command `docker pull -t ${DOCKER_URL}`
#### `make push`
    Runs the command `docker push -t ${DOCKER_URL}`

### Other Deployment and Infrastructure Commands<hr>
#### `make pulumi_test`
    This command collects the defined pulumi output and runs two tests against the EKS cluster 1. Locally creates a kubeconfig.yml and runs kubectl to show the current state of the cluster.
    2. Takes the URL of the cluster and runs a CURL command against it to retrieve the expected JSON response. 
#### `make pulumi_destroy`
    This command will run `pulumi destroy` in a non-interactive mode to teardown the EKS cluster and other infrastructure.