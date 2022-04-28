# Continious Delivery with Flux CD

Contains scripts to set up FluxCD for Continous Delivery in GitOps way.

It syncs the cluster with the described state in a Git repository. 

It works by installing Flux toolkit inside the cluster, which then monitors specified Git repository that contains Kubernetes manifest files and applies them to the cluster.

Contains scripts for:
- Bootstraping Flux
- Creating Flux Sources and Kustomizations
- Setting up "Automated Image Deployments"



## Boostraping Flux 

Installs Flux on the target cluster.

Creates GitHub repository and commits the flux manifests, which then get applied to the cluster and install Flux.


> ***Important***  This is not the same as applying Kubernetes manifests to define your app infrastructure (that is the next step). 
This is just the way of installing Flux. 
Basically, Flux is applying GitOps on itself here - it creates a Git repo containing files that will be added to the cluster in order to install Flux. 


## Creating Flux Sources and Kustomizations 

Sources and Kustomizations are [CRDs](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) created by Flux. 

**Source** - pointer to the app infra repo
**Kustomization** - pointer to the directory inside the Source repo where "kustomize build" should be run


## Setting up Automated Image Deploymnents

Besides keeping our cluster in sync with Git repository, Flux can also do automatic image updates to the repository, after we build our image. 

It monitors the specified image repository for changes, and it updates kubernetes manifest files in the Git repo, which triggers the syncing process between the cluster and the repo. 

For that purpose, it's necessary to create following [CRDs](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/):
- ImageRepository - to tell which image registry to monitor
- ImagePolicy - to tell which tagging policy is used so it can figure out the last image
- ImageUpdateAutomation - to tell which Git repository to write image updates to
