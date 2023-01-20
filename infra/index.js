import * as pulumi from "@pulumi/pulumi";
import * as awsx from "@pulumi/awsx";
import * as eks from "@pulumi/eks"
import * as kubernetes from "@pulumi/kubernetes"

// Create a VPC for our cluster.
const vpc = new awsx.ec2.Vpc("vpc", {});

// Create an EKS cluster with the default configuration.
const cluster = new eks.Cluster("cluster", {
    vpcId: vpc.vpcId,
    publicSubnetIds: vpc.publicSubnetIds,
    privateSubnetIds: vpc.privateSubnetIds,
    nodeAssociatePublicIpAddress: false,
});
const eksProvider = new kubernetes.Provider("eks-provider", {
  kubeconfig: cluster.kubeconfigJson
})

// Deploy the sample API to AWS EKS.
const myDeployment = new kubernetes.apps.v1.Deployment(
  "sample-api",
  {
    metadata: {
      name: "sample-api",
      namespace: "default"
    },
    spec: {
      replicas: 2,
      selector: {
        matchLabels: {
          app: "api"
        }
      },
      template: {
        metadata: {
          labels: {
            app: "api"
          }
        },
        spec: {
          containers: [
            {
              name: "sample-api",
              image: "philjim/simple-api:latest",
              imagePullPolicy: "Always",
              ports: [
                {
                  containerPort: 3000
                }
              ]
            }
          ]
        }
      }
    }
  },
  {
    provider: eksProvider
  }
)
const eksService = new kubernetes.core.v1.Service(
  "api-service",
  {
    metadata: {
      name: "api-service",
      namespace: "default"
    },
    spec: {
      type: "LoadBalancer",
      ports: [
        {
          port: 80,
          targetPort: 3000
        }
      ],
      selector: {
        app: "api"
      }
    }
  },
  {
    provider: eksProvider
  }
)

// Export the cluster's kubeconfig.
export const kubeconfig = cluster.kubeconfig
// Export the URL for the load balanced service.
export const url = eksService.status.apply(
    status => status.loadBalancer.ingress[0].hostname
)