#!/bin/sh

set -e

exit_error() {
  echo "*** ERROR: ${1}"
  exit 1
}

# Parameters check and set defaults
[ -n "$PLUGIN_AWS_ACCESS_KEY_ID" ] && export AWS_ACCESS_KEY_ID=$PLUGIN_AWS_ACCESS_KEY_ID
[ -n "$PLUGIN_AWS_SECRET_ACCESS_KEY" ] && export AWS_SECRET_ACCESS_KEY=$PLUGIN_AWS_SECRET_ACCESS_KEY

# Check if we need to ignore base overlays (needed to avoid errors in k8s-base)
if [ "$(ls overlays | grep -c cluster)" -gt 0 ]; then
  overlays=overlays/*k8s*/
else
  overlays=overlays/*/
fi

# Validate all YAML configuration via Kustomize, Kubeval and Kube-Score
for overlay in $overlays; do
  printf "\nValidating the build of ${overlay}.\n"
  kustomize build $overlay --enable_alpha_plugins > kustomize.yaml

  printf "\nValidating the deploy with Kubeval:\n"
  kubeval --strict --ignore-missing-schemas --kubernetes-version 1.15.0 kustomize.yaml

  printf "\nScoring the deploy with Kube-Score:\n"
  ! kube-score score kustomize.yaml --output-format ci
  rm kustomize.yaml
done

## NO DRY-RUNS UNTIL: https://github.com/argoproj/argo-cd/pull/3675 ##
