#!/usr/bin/env bash

# GitHub username or organization member name that can read the GHCR package.
export GITHUB_USERNAME="your-github-username"

# GitHub token with package read access.
export GITHUB_TOKEN="your-github-token"

# Kubernetes namespace where the image pull secret should be created.
export NAMESPACE="hello-dev"

# Name of the Kubernetes secret that workloads will reference.
export SECRET_NAME="ghcr-creds"

# Container registry hostname. Keep the default for GitHub Container Registry.
export DOCKER_SERVER="ghcr.io"
