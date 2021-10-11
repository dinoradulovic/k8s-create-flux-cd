#!/bin/bash

###################################################################
#Script Name	  :
#Description	  :
#Args         	:
#Author       	: Dino Radulovic
#Email         	: dino.radu@gmail.com
###################################################################

# Flux Infra and App Infra

: '
  There are two infrastructure repositories: 
  1. Flux Infra
  2. App Infra

  Flux Infra contains flux architecture mananifests
  (sources, kustomizations, image update automation).
  App Infra is a source.

  App Infra contains app infrastructure manifests 
  (deployments, services, ingress).
'

APP_NAME=eks-ms-app
export GITHUB_TOKEN=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 # needs to be exported for flux bootstrap
GITHUB_USER=dinoradulovic
APP_INFRA_REPO=https://github.com/dinoradulovic/eks-ms-app-infra.git
STAGING_IMAGE_REPO=ghcr.io/dinoradulovic/eks-ms-app-staging
PRODUCTION_IMAGE_REPO=ghcr.io/dinoradulovic/eks-ms-app-production



# Create a flux repo
FLUX_INFRASTRUCTURE_REPO_NAME=$APP_NAME-flux-infra
# github repo to sync with the cluster
SOURCE_NAME=eks-ms-app-infra
SOURCE_GITHUB_REPO_URL=https://github.com/dinoradulovic/eks-ms-app-infra.git
# image repositories to calculate the latest image tag
# and update manifests in github repo
IMAGE_REPO_URL_STAGING=ghcr.io/dinoradulovic/eks-ms-app-staging
IMAGE_REPO_URL_PRODUCTION=ghcr.io/dinoradulovic/eks-ms-app-production



export GITHUB_TOKEN=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 # needs to be exported for flux bootstrap
GITHUB_USER=dinoradulovic
FLUX_INFRASTRUCTURE_REPO_NAME=$APP_NAME-flux-infra




# export GITHUB_TOKEN=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 # needs to be exported for flux bootstrap
# GITHUB_USER=dinoradulovic
# FLUX_INFRASTRUCTURE_REPO_NAME=eks-ms-flux-infra
# ### Flux Resources ###
# # Source
# SOURCE_NAME=eks-ms-app-infra
# SOURCE_GITHUB_REPO=https://github.com/dinoradulovic/eks-ms-app-infra.git
# # Secret
# SECRET_NAME=$SOURCE_NAME
# SECRET_GITHUB_USER=$GITHUB_USER
# SECRET_GITHUB_TOKEN=$GITHUB_TOKEN
# # Kustomizations
# KUSTOMIZATION_NAME_STAGING=eks-ms-app-staging
# KUSTOMIZATION_NAME_PRODUCTION=eks-ms-app-production
# ### Image Update Automation ###
# # Image Repository
# IMAGE_REPOSITORY_NAME_STAGING=eks-ms-app-staging
# IMAGE_REPOSITORY_NAME_PRODUCTION=eks-ms-app-production
# IMAGE_REPOSITORY_URL_STAGING=ghcr.io/dinoradulovic/eks-ms-app-staging
# IMAGE_REPOSITORY_URL_PRODUCTION=ghcr.io/dinoradulovic/eks-ms-app-production
# # Image Policy
# IMAGE_POLICY_NAME_STAGING=eks-ms-app-staging
# IMAGE_POLICY_NAME_PRODUCTION=eks-ms-app-production
# # Image Update
# IMAGE_UPDATE_NAME=eks-ms-app-infra
# IMAGE_UPDATE_TARGET_REPO=eks-ms-app-infra

# https://stackoverflow.com/questions/59895/how-can-i-get-the-source-directory-of-a-bash-script-from-within-the-script-itsel
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. $SCRIPT_DIR/bootstrap_flux.sh

#######################################
# Creates the GitHub repository and commits the flux manifests to the master branch.
# Then it configures the target cluster to synchronize with the repository.
# Globals:
#   GITHUB_TOKEN
# Arguments:
#   None
#######################################
function main {
  # check $@

  bootstrap_flux
  clone_and_cd_into_repo
  $SCRIPT_DIR/create_flux_resources.sh
  commit_adds_flux-resources
  $SCRIPT_DIR/setup_flux_automated_deployments.sh
  commit_automated_deployments
  git push
}

function check {
  local OPTIND opt i

  while getopts ":cmni:" opt; do
    case $opt in
    i)
      echo "You Chose i"
      input="$OPTARG"
      ;;
    n) echo "You Chose n" ;;
    \?)
      help
      exit 1
      ;;
    esac
  done
  shift "$((OPTIND - 1))"

}

function commit_adds_flux-resources {
  git add .
  git commit -m "Adds source, kustomizations and secret for production and stagign env"
}

function commit_automated_deployments {
  git add .
  git commit -m "Adds flux automated deployments"
}

function clone_and_cd_into_repo() {
  git clone git@github.com:$GITHUB_USER/$REPO_NAME.git
  cd ./$REPO_NAME
}

main $@
