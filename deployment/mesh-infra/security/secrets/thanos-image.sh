#!/usr/bin/env bash

#
# Generate a SealedSecret for pulling the Thanos app
# image.
# Usage:
#
#   $ ./thanos-image.sh TokenYouGotFromSUPSI
#
# where the argument is a GitLab token STAM gave you that includes
# a permission to pull images from https://gitlab.com/.
#
# Notice `kubeseal` needs to be able to access the cluster for this
# script to work. You can also work offline if you like, but you'll
# have to fetch the controller pub key with `kubeseal --fetch-cert`
# beforehand. Read the Sealed Secrets docs for the details.
#

set -e

GITLAB_USR="thanos-gitlab-token"
GITLAB_TOKEN=$1

kubectl create secret docker-registry thanos-image \
        --docker-server="https://gitlab.com" \
        --docker-username="${GITLAB_USR}" \
        --docker-password="${GITLAB_TOKEN}" \
        -o yaml --dry-run='client' | \
    sed 's!^  creationT.*$!  namespace: default\n  annotations:\n    sealedsecrets.bitnami.com/managed: "true"!' | \
    kubeseal -o yaml -w thanos-image.yaml