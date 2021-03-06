#!/bin/bash

###################################################################
#Script Name	  : Setup Flux Automated Image Updates
#Description	  : Configures pointers to:
#                 - prod and staging image repos to find the lastest tags
#                 - github repo (with markers) to update latest tags
#Args         	: None
#Author       	: Dino Radulovic
#Email         	: dino.radu@gmail.com
###################################################################

#######################################
# Configures Automated Image Deployments for Staging and Production environments.
# Creates ImageRepository specifying an image repository to scan.
# Creates ImagePolicy resource specifying the policy to calculate tha latest image version.
# Creates ImageUpdateAutomation resource specifying git repo where marked manifests for image updates are located.
# Globals:
#   None
# Arguments:
#   Microservice Name
#   Microservice Image Repository Url for staging env
#   Microservice Image Repository Url for production env
#######################################
function create_repository_and_policy {
  MICROSERVICE_NAME=$1
  MICROSERVICE_REPOSITORY_URL_STAGING=$2
  MICROSERVICE_REPOSITORY_URL_PRODUCTION=$3

  IMAGE_REPOSITORY_NAME_STAGING=$MICROSERVICE_NAME-staging
  IMAGE_REPOSITORY_NAME_PRODUCTION=$MICROSERVICE_NAME-production
  IMAGE_POLICY_NAME_STAGING=$MICROSERVICE_NAME-staging
  IMAGE_POLICY_NAME_PRODUCTION=$MICROSERVICE_NAME-production

  IMAGE_REPOSITORY_EXPORT_PATH_STAGING=./apps/image-update-automation/staging/$IMAGE_REPOSITORY_NAME_STAGING-image-repository.yaml
  IMAGE_REPOSITORY_EXPORT_PATH_PRODUCTION=./apps/image-update-automation/production/$IMAGE_REPOSITORY_NAME_PRODUCTION-image-repository.yaml
  IMAGE_POLICY_EXPORT_PATH_STAGING=./apps/image-update-automation/staging/$IMAGE_POLICY_NAME_STAGING-image-policy.yaml
  IMAGE_POLICY_EXPORT_PATH_PRODUCTION=./apps/image-update-automation/production/$IMAGE_POLICY_NAME_PRODUCTION-image-policy.yaml

  if [ ! -d "./apps/flux-system" ]; then
    echo "Error: Make sure your are in a flux boostraped directory."
    exit 1
  fi

  flux create image repository $IMAGE_REPOSITORY_NAME_STAGING \
    --image=$MICROSERVICE_REPOSITORY_URL_STAGING \
    --interval=1m \
    --export >$IMAGE_REPOSITORY_EXPORT_PATH_STAGING

  flux create image policy $IMAGE_POLICY_NAME_STAGING \
    --image-ref=$IMAGE_REPOSITORY_NAME_STAGING \
    --select-numeric=asc \
    --filter-regex='^tmstp-(?P<ts>.*)' \
    --filter-extract='$ts' \
    --export >$IMAGE_POLICY_EXPORT_PATH_STAGING

  flux create image repository $IMAGE_REPOSITORY_NAME_PRODUCTION \
    --image=$MICROSERVICE_REPOSITORY_URL_PRODUCTION \
    --interval=1m \
    --export >$IMAGE_REPOSITORY_EXPORT_PATH_PRODUCTION

  flux create image policy $IMAGE_POLICY_NAME_PRODUCTION \
    --image-ref=$IMAGE_REPOSITORY_NAME_PRODUCTION \
    --select-numeric=asc \
    --filter-regex='^tmstp-(?P<ts>.*)' \
    --filter-extract='$ts' \
    --export >$IMAGE_POLICY_EXPORT_PATH_PRODUCTION
}

#######################################
# Creates ImageUpdateAutomation CRD
# specifying git repo where marked manifests for image updates are located.
# Globals:
#   APP_NAME
# Arguments:
#   None
#######################################
function create_image_update {
  IMAGE_UPDATE_EXPORT_PATH=./apps/image-update-automation/$APP_NAME-image-update.yaml
  flux create image update $APP_NAME \
    --git-repo-ref=$APP_NAME \
    --git-repo-path="./" \
    --checkout-branch=master \
    --push-branch=master \
    --author-name=fluxcdbot \
    --author-email=fluxcdbot@users.noreply.github.com \
    --commit-template="{{range .Updated.Images}}{{println .}}{{end}}" \
    --export >$IMAGE_UPDATE_EXPORT_PATH
}

mkdir -p ./apps/image-update-automation/staging ./apps/image-update-automation/production

create_repository_and_policy microservice-one $MICROSEVICE_ONE_IMAGE_REPOSITORY_URL_STAGING $MICROSEVICE_ONE_IMAGE_REPOSITORY_URL_PRODUCTION
create_repository_and_policy microservice-two $MICROSEVICE_TWO_IMAGE_REPOSITORY_URL_STAGING $MICROSEVICE_TWO_IMAGE_REPOSITORY_URL_PRODUCTION
create_image_update
