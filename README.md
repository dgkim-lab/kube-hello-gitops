# kube-hello-gitops

Sample Argo CD GitOps repository using the app-of-apps pattern and Kustomize overlays.

## Layout

- `argocd/root-application.yaml`: bootstrap Argo CD `Application`
- `apps/dev/`: child Argo CD applications for the `dev` environment
- `workloads/hello-app/base/`: shared Kubernetes manifests
- `workloads/hello-app/overlays/dev/`: environment-specific Kustomize overlay

## Prerequisites

- A Kubernetes cluster
- Argo CD installed in the `argocd` namespace
- `kubectl`
- `kustomize` or `kubectl kustomize`

## Bootstrap

1. Confirm the `repoURL` values in `argocd/root-application.yaml` and `apps/dev/hello-app.yaml` match the repository URL Argo CD can access.
2. Apply the root application:

   ```sh
   kubectl apply -f argocd/root-application.yaml
   ```

3. In Argo CD, sync the `root-dev` application. Argo CD will then create and manage the `hello-app-dev` child application.

## Local Access

The sample workload exposes a `ClusterIP` service, so it is reachable inside the cluster only. For local testing, port-forward the service:

```sh
./scripts/port-forward-hello-app.sh
```

Then open:

```text
http://localhost:8080
```

Optional overrides:

```sh
LOCAL_PORT=8081 ./scripts/port-forward-hello-app.sh
```

## Private GHCR Image Pull Secret

If you deploy a private image from GitHub Container Registry, create a Kubernetes image pull secret before syncing the workload:

```sh
cp scripts/ghcr-secret.env.example.sh scripts/ghcr-secret.env.sh
source scripts/ghcr-secret.env.sh
./scripts/create-ghcr-pull-secret.sh
```

Required environment variables are documented in [scripts/ghcr-secret.env.example.sh](/home/dgkim/git-dgkim-lab/kube-hello-gitops/scripts/ghcr-secret.env.example.sh:1). The script creates or updates a `docker-registry` secret in the target namespace without storing the token in Git.

## Expected Result

After sync, Argo CD deploys the `hello-app` sample workload into the `hello-dev` namespace. The workload exposes a ClusterIP service on port `80` that targets the container on port `8080`.
