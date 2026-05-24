# Kustomize Quick Notes

Kustomize builds final Kubernetes YAML from a selected directory that contains `kustomization.yaml`.

The selected directory is the entrypoint. It can reference other files or directories.

In this repo, Argo CD points to the dev overlay:

```text
workloads/kube-hello-app/overlays/dev
```

That directory has:

```yaml
resources:
  - ../../base
```

So the flow is:

```text
overlays/dev/kustomization.yaml -> ../../base -> deployment.yaml, service.yaml, etc.
```

The base is not read automatically. It is read because the overlay references it.

## Base And Overlay

`base` usually contains shared Kubernetes manifests:

```text
deployment.yaml
service.yaml
serviceaccount.yaml
ingress.yaml
kustomization.yaml
```

`overlays/dev` contains environment-specific changes, such as:

```yaml
namespace: hello-dev

resources:
  - ../../base

labels:
  - pairs:
      app.kubernetes.io/environment: dev
```

`base` and `overlays/dev` are conventions, not Kubernetes requirements. The names can change as long as `kustomization.yaml` references the correct paths.

## Useful Commands

Preview the final YAML:

```sh
kubectl kustomize workloads/kube-hello-app/overlays/dev
```

Apply the final YAML directly with kubectl:

```sh
kubectl apply -k workloads/kube-hello-app/overlays/dev
```

Do not apply `kustomization.yaml` with `-f`:

```sh
kubectl apply -f workloads/kube-hello-app/overlays/dev/kustomization.yaml
```

That tries to apply the Kustomize config file itself as a Kubernetes resource.

## Argo CD

Argo CD reads `kustomization.yaml` when an `Application` points to a Kustomize directory:

```yaml
spec:
  source:
    path: workloads/kube-hello-app/overlays/dev
```

Argo CD builds the final YAML from that directory and applies it to the cluster.
