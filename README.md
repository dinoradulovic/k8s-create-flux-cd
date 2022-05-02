# Continious Delivery with Flux CD

This repo is part of the bundle. 

| PARAM | NOTES |
| ------ | ------ |
| [k8s-create-eks-fargate](https://github.com/dinoradulovic/k8s-create-eks-fargate)| scripts to create Kubernetes cluster on EKS with Fargate |
| **[k8s-create-flux-cd](https://github.com/dinoradulovic/k8s-create-flux-cd)** | **scripts to setup GitOps with FluxCD** |
| [k8s-microservice-one](https://github.com/dinoradulovic/k8s-microservice-one) | first sample microservice to be deployed into cluster |
| [k8s-microservice-two](https://github.com/dinoradulovic/k8s-microservice-two) | second sample microservice to be deployed into cluster |
| [k8s-microservices-app-infra](https://github.com/dinoradulovic/k8s-microservices-app-infra) | infrastructure manifest files for two microservices app |

Contains scripts to set up FluxCD for Continous Delivery in GitOps way.

It syncs the cluster with the described state in a Git repository.

It works by installing Flux toolkit inside the cluster, which then monitors the specified Git repository that contains Kubernetes manifest files and applies them to the cluster.

Contains scripts for:
- Bootstraping Flux
- Creating Flux Sources and Kustomizations
- Setting up "Automated Image Deployments" (for two example microservices)

## Boostraping Flux 

Installs FluxCD on the target cluster.

Creates GitHub repository and commits the flux manifests, which then get applied to the cluster and install FluxCD.


> ***Important***  This is not the same as applying Kubernetes manifests to define your app infrastructure (that is the next step). 
This is just the way of installing FluxCD. 
Basically, FluxCD is applying GitOps on itself here - it creates a Git repo containing files that will be added to the cluster in order to install FluxCD. 


## Creating Flux Sources and Kustomizations 

Sources and Kustomizations are [CRDs](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) created by Flux. 

**Source** - pointer to the app infra repo

**Kustomization** - pointer to the directory inside the Source repo where "kustomize build" should be run


## Setting up Automated Image Deploymnents

Besides keeping the cluster in sync with Git repository, FluxCD can also do automatic image updates to the git repository, after the image is built and pushed to image repository. 

It monitors the specified image repository for changes, and it updates kubernetes manifest files in the Git repo, which triggers the syncing process between the cluster and the repo. 

For that purpose, it's necessary to create following [CRDs](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/):
- ImageRepository - to tell Flux which image registry to monitor
- ImagePolicy - to tell Flux which tagging policy is used so it can figure out the last image
- ImageUpdateAutomation - to tell Flux which Git repository to write image updates to


## Uninstalling Flux 

```flux uninstall --namespace=flux-system```

This command uninstalls Flux components, CRD's and namespace, but it wouldn't affect any app resources preivously created with Flux. 



