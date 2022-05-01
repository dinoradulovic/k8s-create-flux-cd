#!/bin/bash

###################################################################
#Script Name	  : Create Flux Resources
#Description	  : Generates files(flux crds) for setting up GitOps CD
#Args         	: None
#Author       	: Dino Radulovic
#Email         	: dino.radu@gmail.com
###################################################################

# generate all flux manifests into this folder
MANIFESTS_EXPORT_PATH=./apps/deployments

if [ ! -d "./apps/flux-system" ]; then
  echo "Error: Make sure your are in a flux boostraped directory."
  exit 1
fi

#######################################
# Create a Source (GitRepository) for k8s manifests.
# Globals:
#   GITHUB_USER, GITHUB_TOKEN,
#   MANIFESTS_EXPORT_PATH,
#   APP_NAME, APP_INFRA_REPO_URL
# Arguments:
#   None
#######################################
function create_source_and_secret {
  SECRET_NAME=$APP_NAME
  SOURCE_NAME=$APP_NAME
  SOURCE_EXPORT_PATH=$MANIFESTS_EXPORT_PATH/$SOURCE_NAME-source.yaml
  SECRET_EXPORT_PATH=$MANIFESTS_EXPORT_PATH/$SECRET_NAME-secret.yaml

  flux create secret git $SECRET_NAME \
    --url $APP_INFRA_REPO_URL \
    --username $GITHUB_USER \
    --password $GITHUB_TOKEN \
    --export >$SECRET_EXPORT_PATH

  flux create source git $SOURCE_NAME \
    --url $APP_INFRA_REPO_URL \
    --branch master \
    --interval 30s \
    --secret-ref $SECRET_NAME \
    --export >$SOURCE_EXPORT_PATH
}

#######################################
# Create a Kustomization resources for staging and production environments
# referencing a path in Source object where the manifests are located.
# Globals:
#   APP_NAME,
#   MANIFESTS_EXPORT_PATH
# Arguments:
#   None
#######################################
function create_kustomizations {
  STAGING_KUSTOMIZATION_NAME=$APP_NAME-staging
  PRODUCTION_KUSTOMIZATION_NAME=$APP_NAME-production
  STAGING_MANIFESTS_REPO_PATH="./deploy/overlay/staging"
  KUSTOMIZATION_STAGING_EXPORT_PATH=$MANIFESTS_EXPORT_PATH/$STAGING_KUSTOMIZATION_NAME-kustomization.yaml
  PRODUCTION_MANIFESTS_REPO_PATH="./deploy/overlay/production"
  PRODUCTION_EXPORT_PATH=$MANIFESTS_EXPORT_PATH/$PRODUCTION_KUSTOMIZATION_NAME-kustomization.yaml

  flux create kustomization $STAGING_KUSTOMIZATION_NAME \
    --source $APP_NAME \
    --path $STAGING_MANIFESTS_REPO_PATH \
    --prune true \
    --validation client \
    --interval 1m \
    --export >$KUSTOMIZATION_STAGING_EXPORT_PATH

  flux create kustomization $PRODUCTION_KUSTOMIZATION_NAME \
    --source $APP_NAME \
    --path $PRODUCTION_MANIFESTS_REPO_PATH \
    --prune true \
    --validation client \
    --interval 1m \
    --export >$PRODUCTION_EXPORT_PATH
}

mkdir -p $MANIFESTS_EXPORT_PATH
create_source_and_secret
create_kustomizations
