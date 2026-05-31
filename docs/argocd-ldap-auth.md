# Argo CD LDAP Authentication

This setup configures Argo CD's bundled Dex server to authenticate against LDAP
with anonymous search. The LDAP hostname and base DNs are local environment
values, so they are configured by a manual helper script instead of GitOps.

Run the script after Argo CD is installed and before or after deploying the
root Argo CD application. It only requires `kubectl` access to the cluster.

## Configure Argo CD

The default configuration assumes:

```text
LDAP host: ldap.dgkim.net:389
User base DN: ou=people,dc=dgkim,dc=net
Group base DN: ou=groups,dc=dgkim,dc=net
Admin group: argocd-admins
```

To configure local LDAP values:

```shell
cp scripts/argocd-ldap.env.example.sh scripts/argocd-ldap.env.sh
vi scripts/argocd-ldap.env.sh

set -a
. ./scripts/argocd-ldap.env.sh
set +a

./scripts/configure-argocd-ldap.sh
```

Do not commit `scripts/argocd-ldap.env.sh`.

The script creates or updates:

```text
argocd/argocd-cm
argocd/argocd-rbac-cm
```

Restart the Argo CD API server and Dex server after applying the config:

```shell
kubectl -n argocd rollout restart deployment/argocd-server
kubectl -n argocd rollout restart deployment/argocd-dex-server
```

## Verify

Open:

```text
https://argocd.k3s.dgkim.net
```

Use the `LDAP` login option. Members of the configured LDAP admin group receive
Argo CD admin permissions. Other LDAP users receive read-only permissions.
