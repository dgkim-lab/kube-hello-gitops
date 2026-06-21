# Fresh Install

This guide starts after the k3s cluster is reachable with `kubectl`.

The Argo CD installation itself is maintained in the companion bootstrap
repository:

```text
../kube-hello-argocd
```

## 1. Install Argo CD

From the `kube-hello-argocd` repository:

```shell
./scripts/install-argocd.sh
```

Confirm the Argo CD pods are ready:

```shell
kubectl -n argocd get pods
```

## 2. Configure Argo CD LDAP

Return to this repository:

```shell
cd ../kube-hello-gitops
```

Create the local LDAP environment file:

```shell
cp scripts/argocd-ldap.env.example.sh scripts/argocd-ldap.env.sh
vi scripts/argocd-ldap.env.sh
```

Load it and apply the Argo CD LDAP config:

```shell
set -a
. ./scripts/argocd-ldap.env.sh
set +a

./scripts/configure-argocd-ldap.sh
```

Restart Argo CD so Dex and the API server load the new config:

```shell
kubectl -n argocd rollout restart deployment/argocd-server
kubectl -n argocd rollout restart deployment/argocd-dex-server
kubectl -n argocd rollout status deployment/argocd-server --timeout=180s
kubectl -n argocd rollout status deployment/argocd-dex-server --timeout=180s
```

## 3. Create Manual Secrets

Create the GHCR image pull secret if private GHCR images are used:

```shell
cp scripts/ghcr-secret.env.example.sh scripts/ghcr-secret.env.sh
vi scripts/ghcr-secret.env.sh

set -a
. ./scripts/ghcr-secret.env.sh
set +a

./scripts/create-ghcr-pull-secret.sh
```

Create the Route53 credentials secret if cert-manager will issue Let's Encrypt
certificates through DNS-01:

```shell
cp scripts/route53-secret.env.example.sh scripts/route53-secret.env.sh
vi scripts/route53-secret.env.sh

set -a
. ./scripts/route53-secret.env.sh
set +a

./scripts/create-route53-credentials-secret.sh
```

## 4. Bootstrap GitOps

Apply the root Argo CD application:

```shell
kubectl apply -f argocd/root-application.yaml
```

Argo CD will create the child applications from `apps/dev`.

Check sync state:

```shell
kubectl get applications -n argocd
```

## 5. Verify Access

Verify Argo CD:

```text
https://argocd.k3s-test.dgkim.net
```

Use the LDAP login option. Members of the configured LDAP admin group receive
Argo CD admin permissions.

Verify workloads:

```shell
kubectl get pods -A
kubectl get ingress -A
```

Local-only DNS such as `argocd.k3s-test.dgkim.net -> 192.168.1.26` must already be
configured before browser access works.
