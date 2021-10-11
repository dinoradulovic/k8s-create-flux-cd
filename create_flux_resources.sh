#!/bin/bash

###################################################################
#Script Name	  : Create Flux Resources
#Description	  : Generates necessary files for setting up GitOps CD
#Args         	:
#Author       	: Dino Radulovic
#Email         	: dino.radu@gmail.com
###################################################################


GITHUB_USERNAME=dinoradulovic
GITHUB_TOKEN=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

SOURCE_NAME=eks-ms-app-infra
SECRET_NAME=$SOURCE_NAME
SOURCE_GITHUB_REPO=https://github.com/dinoradulovic/eks-ms-app-infra.git
STAGING_KUSTOMIZATION_NAME=eks-ms-app-staging
PRODUCTION_KUSTOMIZATION_NAME=eks-ms-app-production

if [ ! -d "./apps/flux-system" ]; then
  echo "Error: Make sure your are in a flux boostraped directory."
  exit 1
fi


#######################################
# Create a Source (GitRepository) for k8s manifests.
# Globals:
#   GITHUB_TOKEN
# Arguments:
#   None
#######################################
function create_source_and_secret {
  RESOURCES_EXPORT_PATH=./apps/deployments
  SOURCE_EXPORT_PATH=$RESOURCES_EXPORT_PATH/$SOURCE_NAME-source.yaml
  SECRET_EXPORT_PATH=$RESOURCES_EXPORT_PATH/$SECRET_NAME-secret.yaml

  flux create secret git $SECRET_NAME \
    --url $SOURCE_GITHUB_REPO \
    --username $GITHUB_USERNAME \
    --password $GITHUB_TOKEN \
    --export >$SECRET_EXPORT_PATH

  flux create source git $SOURCE_NAME \
    --url $SOURCE_GITHUB_REPO \
    --branch master \
    --interval 30s \
    --secret-ref $SECRET_NAME \
    --export >$SOURCE_EXPORT_PATH
}

#######################################
# Create a Kustomization resources for staging and production environments
# referencing a path in Source object where the manifest are located.
# Globals:
#   None
# Arguments:
#   None
#######################################
function create_kustomizations {
  STAGING_MANIFESTS_REPO_PATH="./deploy/overlay/staging"
  STAGING_EXPORT_PATH=$RESOURCES_EXPORT_PATH/$STAGING_KUSTOMIZATION_NAME-staging.yaml
  PRODUCTION_MANIFESTS_REPO_PATH="./deploy/overlay/production"
  PRODUCTION_EXPORT_PATH=$RESOURCES_EXPORT_PATH/$PRODUCTION_KUSTOMIZATION_NAME-production.yaml

  flux create kustomization $STAGING_KUSTOMIZATION_NAME \
    --source $SOURCE_NAME \
    --path $STAGING_MANIFESTS_REPO_PATH \
    --prune true \
    --validation client \
    --interval 1m \
    --export >$STAGING_EXPORT_PATH

  flux create kustomization $PRODUCTION_KUSTOMIZATION_NAME \
    --source $SOURCE_NAME \
    --path $PRODUCTION_MANIFESTS_REPO_PATH \
    --prune true \
    --validation client \
    --interval 1m \
    --export >$PRODUCTION_EXPORT_PATH
}

mkdir -p $RESOURCES_EXPORT_PATH
create_source_and_secret
create_kustomizations
