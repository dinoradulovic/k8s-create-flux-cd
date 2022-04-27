#!/bin/bash

###################################################################
#Script Name	  : Bootstrap Flux
#Description	  : Creates github repo containing flux architecture manifests
#Args         	: None
#Author       	: Dino Radulovic
#Email         	: dino.radu@gmail.com
###################################################################

#######################################
# Creates GitHub repository and commits the flux manifests to the master branch.
# Then it configures the target cluster to synchronize with the repository.
# Globals:
#   GITHUB_TOKEN, GITHUB_USER, FLUX_INFRA_REPO_NAME
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
