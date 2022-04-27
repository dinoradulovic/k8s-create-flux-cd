#!/bin/bash

###################################################################
#Script Name	  : Setup FluxCD
#Description	  : Creates infra repos and deploys flux components to cluster
#Args         	: None
#Author       	: Dino Radulovic
#Email         	: dino.radu@gmail.com
###################################################################

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

. $SCRIPT_DIR/.env

#######################################
# Bootstraps GitHub repository(Flux Infra) with Flux toolkit components.
# Inside of that repo, it generates YAML files for setting up:
#   - pointers to the external git repo (App Infra) where the app infrastructure is stored.
#   - paths to Kustomization files inside of App Infra repo
# It also configures Automated Image Updates.
# Globals:
#   SCRIPT_DIR, GITHUB_USER, FLUX_INFRA_REPO_NAME
# Arguments:
#   None
#######################################
function main {
  cd $SCRIPT_DIR
  cd ../
  $SCRIPT_DIR/bootstrap_flux.sh
  git clone git@github.com:$GITHUB_USER/$FLUX_INFRA_REPO_NAME.git
  cd ./$FLUX_INFRA_REPO_NAME
  $SCRIPT_DIR/create_flux_resources.sh
  git add .
  git commit -m "Adds source, kustomizations and secret for production and staging env"
  $SCRIPT_DIR/setup_flux_automated_deployments.sh
  git add .
  git commit -m "Adds flux automated deployments"
  git push
}

main
