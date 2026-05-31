# Argo Rollouts Plugin Quick Notes

The Argo Rollouts kubectl plugin adds local commands for inspecting and promoting `Rollout` resources.

The plugin command is:

```sh
kubectl argo rollouts
```

The binary installed on the local machine is:

```text
kubectl-argo-rollouts
```

This is separate from the Argo Rollouts controller running in the cluster.

## Check Rollout Status

Check the Rollout resource:

```sh
kubectl get rollout kube-hello-app -n hello-dev
```

Show detailed rollout state:

```sh
kubectl argo rollouts get rollout kube-hello-app -n hello-dev
```

Wait until the rollout reaches a terminal state:

```sh
kubectl argo rollouts status kube-hello-app -n hello-dev
```

Watch pods during rollout:

```sh
kubectl get pods -n hello-dev -l app=kube-hello-app -w
```

## Canary Promotion

The canary test uses a pause step:

```yaml
steps:
  - setWeight: 20
  - pause: {}
  - setWeight: 100
```

At the pause, the rollout waits until it is promoted.

Promote to the next step:

```sh
kubectl argo rollouts promote kube-hello-app -n hello-dev
```

Skip the remaining steps and fully promote:

```sh
kubectl argo rollouts promote kube-hello-app -n hello-dev --full
```

Abort the rollout if the canary version is bad:

```sh
kubectl argo rollouts abort kube-hello-app -n hello-dev
```

## Blue-Green Promotion

The blue-green test uses manual promotion:

```yaml
blueGreen:
  activeService: kube-hello-app
  previewService: kube-hello-app-preview
  autoPromotionEnabled: false
```

The active Service receives normal traffic:

```text
kube-hello-app
```

The preview Service exposes the new version before promotion:

```text
kube-hello-app-preview
```

Test the preview version with port-forward:

```sh
kubectl port-forward svc/kube-hello-app-preview 8081:80 -n hello-dev
```

Call the preview Service:

```sh
curl http://localhost:8081/
```

Compare with the active Service:

```sh
kubectl port-forward svc/kube-hello-app 8080:80 -n hello-dev
curl http://localhost:8080/
```

Promote the preview version to active:

```sh
kubectl argo rollouts promote kube-hello-app -n hello-dev
```

Check that the active Service now points to the promoted ReplicaSet:

```sh
kubectl get endpoints kube-hello-app -n hello-dev
kubectl argo rollouts get rollout kube-hello-app -n hello-dev
```

Abort before promotion if the preview version is bad:

```sh
kubectl argo rollouts abort kube-hello-app -n hello-dev
```

## Argo CD UI

Argo CD may show Rollout actions such as `Promote`, `Promote Full`, `Abort`, or `Retry` on the Rollout resource.

If those actions are not visible, use the local kubectl plugin.

Argo CD promotion actions and the local plugin both operate on the same `Rollout` resource in the cluster.

## Install The Local Plugin

Install the plugin version that matches the controller version.

This repo installs Argo Rollouts `v1.9.0`, so install the `v1.9.0` plugin:

```sh
curl -LO https://github.com/argoproj/argo-rollouts/releases/download/v1.9.0/kubectl-argo-rollouts-linux-amd64
chmod +x kubectl-argo-rollouts-linux-amd64
sudo mv kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts
```

Verify installation:

```sh
kubectl argo rollouts version
```

List installed kubectl plugins:

```sh
kubectl plugin list
```
