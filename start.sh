#!/bin/sh

set -e

function exit_error {
  echo "*** ERROR: ${1}"
  exit 1
}

# Parameters check and set defaults
[ -n "$PLUGIN_AWS_ACCESS_KEY_ID" ] && export AWS_ACCESS_KEY_ID=$PLUGIN_AWS_ACCESS_KEY_ID
[ -n "$PLUGIN_AWS_SECRET_ACCESS_KEY" ] && export AWS_SECRET_ACCESS_KEY=$PLUGIN_AWS_SECRET_ACCESS_KEY

# Validate all YAML configuration via Kustomize, Kubeval and Kube-Score
for overlay in overlays/*/; do
  echo -e "\nValidating the build of ${overlay}."
  kustomize build $overlay --enable_alpha_plugins > kustomize.yaml
  echo -e "\nValidating the deploy with Kubeval:"
  kubeval --strict --kubernetes-version 1.15.0 kustomize.yaml
  echo -e "\nScoring the deploy with Kube-Score:"
  ! kube-score score kustomize.yaml --output-format ci
  rm kustomize.yaml
done

## NO DRY-RUNS UNTIL: https://github.com/argoproj/argo-cd/pull/3675 ##
