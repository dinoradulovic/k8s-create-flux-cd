#!/bin/bash

###################################################################
#Script Name	  :
#Description	  :
#Args         	:
#Author       	: Dino Radulovic
#Email         	: dino.radu@gmail.com
###################################################################

# personal access token
export GITHUB_TOKEN=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m

IMAGE_REPOSITORY_NAME_STAGING=eks-ms-app-staging
IMAGE_REPOSITORY_PATH_STAGING=ghcr.io/dinoradulovic/eks-ms-app-staging
IMAGE_POLICY_NAME_STAGING=eks-ms-app-staging
IMAGE_REPOSITORY_NAME_PRODUCTION=eks-ms-app-production
IMAGE_REPOSITORY_PATH_PRODUCTION=ghcr.io/dinoradulovic/eks-ms-app-production
IMAGE_POLICY_NAME_PRODUCTION=eks-ms-app-production
IMAGE_UPDATE_NAME=eks-ms-app-infra
GITHUB_APP_INFRA_REPO_REF=eks-ms-app-infra

#######################################
# Configures Automated Image Deployments for Staging and Production environments.
# Creates ImageRepository specifying an image repository to scan.
# Creates ImagePolicy resource specifying the policy to calculate tha latest image version.
# Creates ImageUpdateAutomation resource specifying git repo where marked manifests for image updates are located.
# Globals:
#   None
# Arguments:
#   None
#######################################
function create_automated_image_deployments {
  mkdir -p ./apps/image-update-automation/staging ./apps/image-update-automation/production

  IMAGE_REPOSITORY_EXPORT_PATH_STAGING=./apps/image-update-automation/staging/$IMAGE_REPOSITORY_NAME_STAGING-image-repository.yaml
  IMAGE_REPOSITORY_EXPORT_PATH_PRODUCTION=./apps/image-update-automation/production/$IMAGE_REPOSITORY_NAME_PRODUCTION-image-repository.yaml
  IMAGE_POLICY_EXPORT_PATH_STAGING=./apps/image-update-automation/staging/$IMAGE_POLICY_NAME_STAGING-image-policy.yaml
  IMAGE_POLICY_EXPORT_PATH_PRODUCTION=./apps/image-update-automation/production/$IMAGE_POLICY_NAME_PRODUCTION-image-policy.yaml
  IMAGE_UPDATE_EXPORT_PATH=./apps/image-update-automation/$IMAGE_UPDATE_NAME-image-update.yaml

  # IMAGE_REPOSITORY_NAME_STAGING=eks-ms-app-staging
  # IMAGE_REPOSITORY_PATH_STAGING=ghcr.io/dinoradulovic/eks-ms-app-staging
  # IMAGE_REPOSITORY_EXPORT_PATH_STAGING=./apps/image-update-automation/staging/$IMAGE_REPOSITORY_NAME_STAGING-image-repository.yaml

  # IMAGE_POLICY_NAME_STAGING=eks-ms-app-staging
  # IMAGE_POLICY_EXPORT_PATH_STAGING=./apps/image-update-automation/staging/$IMAGE_POLICY_NAME_STAGING-image-policy.yaml

  # IMAGE_REPOSITORY_NAME_PRODUCTION=eks-ms-app-production
  # IMAGE_REPOSITORY_PATH_PRODUCTION=ghcr.io/dinoradulovic/eks-ms-app-production
  # IMAGE_REPOSITORY_EXPORT_PATH_PRODUCTION=./apps/image-update-automation/production/$IMAGE_REPOSITORY_NAME_PRODUCTION-image-repository.yaml

  # IMAGE_POLICY_NAME_PRODUCTION=eks-ms-app-production
  # IMAGE_POLICY_EXPORT_PATH_PRODUCTION=./apps/image-update-automation/production/$IMAGE_POLICY_NAME_PRODUCTION-image-policy.yaml

  # IMAGE_UPDATE_NAME=eks-ms-app-infra
  # GITHUB_APP_INFRA_REPO_REF=eks-ms-app-infra
  # IMAGE_UPDATE_EXPORT_PATH=./apps/image-update-automation/eks-ms-app-infra-automation.yaml

  if [ ! -d "./apps/flux-system" ]; then
    echo "Error: Make sure your are in a flux boostraped directory."
    exit 1
  fi

  flux create image repository $IMAGE_REPOSITORY_NAME_STAGING \
    --image=$IMAGE_REPOSITORY_PATH_STAGING \
    --interval=1m \
    --export >$IMAGE_REPOSITORY_EXPORT_PATH_STAGING

  flux create image policy $IMAGE_POLICY_NAME_STAGING \
    --image-ref=$IMAGE_REPOSITORY_NAME_STAGING \
    --select-numeric=asc \
    --filter-regex='^tmstp-(?P<ts>.*)' \
    --filter-extract='$ts' \
    --export >$IMAGE_POLICY_EXPORT_PATH_STAGING

  flux create image repository $IMAGE_REPOSITORY_NAME_PRODUCTION \
    --image=$IMAGE_REPOSITORY_PATH_PRODUCTION \
    --interval=1m \
    --export >$IMAGE_REPOSITORY_EXPORT_PATH_PRODUCTION

  flux create image policy $IMAGE_POLICY_NAME_PRODUCTION \
    --image-ref=$IMAGE_REPOSITORY_NAME_PRODUCTION \
    --select-numeric=asc \
    --filter-regex='^tmstp-(?P<ts>.*)' \
    --filter-extract='$ts' \
    --export >$IMAGE_POLICY_EXPORT_PATH_PRODUCTION

  flux create image update $IMAGE_UPDATE_NAME \
    --git-repo-ref=$GITHUB_APP_INFRA_REPO_REF \
    --git-repo-path="./" \
    --checkout-branch=master \
    --push-branch=master \
    --author-name=fluxcdbot \
    --author-email=fluxcdbot@users.noreply.github.com \
    --commit-template="{{range .Updated.Images}}{{println .}}{{end}}" \
    --export >$IMAGE_UPDATE_EXPORT_PATH
}

create_automated_image_deployments
