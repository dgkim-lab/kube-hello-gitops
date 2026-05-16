# kube-hello-gitops

Sample Argo CD GitOps repository using the app-of-apps pattern and Kustomize overlays.

## Layout

- `argocd/root-application.yaml`: bootstrap Argo CD `Application`
- `apps/dev/`: child Argo CD applications for the `dev` environment
- `workloads/hello-app/base/`: shared Kubernetes manifests
- `workloads/kube-hello-app/base/`: manifests for the Node.js app published to GHCR
- `workloads/hello-app/overlays/dev/`: environment-specific Kustomize overlay
- `workloads/kube-hello-app/overlays/dev/`: environment-specific overlay for the GHCR-backed app

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

3. In Argo CD, sync the `root-dev` application. Argo CD will then create and manage the `hello-app-dev` and `kube-hello-app-dev` child applications.

## Local Access

Both workloads expose `ClusterIP` services, so they are reachable inside the cluster only. For local testing, port-forward either service.

Sample echo app:

```sh
./scripts/port-forward-hello-app.sh
```

Then open:

```text
http://localhost:8080
```

Node.js app from `kube-hello-app`:

```sh
./scripts/port-forward-kube-hello-app.sh
```

Then open:

```text
http://localhost:3000
```

Optional overrides for either script:

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

`kube-hello-app` expects that secret to be named `ghcr-creds` in the `hello-dev` namespace. Its `ServiceAccount` references that secret so Kubernetes can pull `ghcr.io/dgkim-lab/kube-hello-app:latest` when the package is private.

## Expected Result

After sync, Argo CD deploys both `hello-app` and `kube-hello-app` into the `hello-dev` namespace. Each workload exposes a `ClusterIP` service on port `80`; `hello-app` targets container port `8080` and `kube-hello-app` targets container port `3000`.
