#!/bin/bash

###################################################################
#Script Name	  : Bootstrap Flux
#Description	  : Creates github repo containing flux architecture manifests
#Args         	: FLUX_INFRA_REPO_NAME - name of the repo the flux is going to create for it's components
#Author       	: Dino Radulovic
#Email         	: dino.radu@gmail.com
###################################################################

FLUX_INFRA_REPO_NAME=$1

if [ -z "$FLUX_INFRA_REPO_NAME" ]; then
  echo "Exiting..."
  echo
  echo "Need to provide the name of the repo that flux is going to create for it's components"
  exit 1
fi


#######################################
# Creates GitHub repository and commits the flux manifests to the master branch.
# Then it configures the target cluster to synchronize with the repository.
# Globals:
#   GITHUB_TOKEN, GITHUB_USER
# Arguments:
#   None
#######################################
function bootstrap_flux {
  flux bootstrap github \
    --owner $GITHUB_USER \
    --repository $FLUX_INFRA_REPO_NAME \
    --branch master \
    --path apps \
    --personal \
    --components-extra=image-reflector-controller,image-automation-controller \
    --token-auth
}

bootstrap_flux
