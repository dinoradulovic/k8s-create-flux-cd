#!/bin/bash

###################################################################
#Script Name	  : Bootstrap Flux
#Description	  : Creates github repo containing flux architecture manifests
#Args         	: None
#Author       	: Dino Radulovic
#Email         	: dino.radu@gmail.com
###################################################################

# Github's (P)ersonal (A)ccess (T)oken
export GITHUB_TOKEN=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

GITHUB_USER=dinoradulovic
REPO_NAME=eks-ms-flux-infra

#######################################
# Creates the GitHub repository and commits the flux manifests to the master branch.
# Then it configures the target cluster to synchronize with the repository.
# Globals:
#   GITHUB_TOKEN
# Arguments:
#   None
#######################################
function bootstrap_flux {
  flux bootstrap github \
    --owner $GITHUB_USER \
    --repository $REPO_NAME \
    --branch master \
    --path apps \
    --personal \
    --components-extra=image-reflector-controller,image-automation-controller \
    --token-auth
}
