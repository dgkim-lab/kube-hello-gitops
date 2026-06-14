# Argo CD LDAP and Keycloak Authentication

This setup configures Argo CD's bundled Dex server to authenticate against LDAP
with anonymous search. It can also add Keycloak as a second Dex login option.
The LDAP hostname, base DNs, and optional Keycloak client values are local
environment values, so they are configured by a manual helper script instead of
GitOps.

Run the script after Argo CD is installed and before or after deploying the
root Argo CD application. It only requires `kubectl` access to the cluster.

## Configure Argo CD

The default configuration assumes:

```text
LDAP host: ldap.dgkim.net:389
User base DN: ou=people,dc=dgkim,dc=net
Group base DN: ou=groups,dc=dgkim,dc=net
LDAP admin group: argocd-admins
```

To configure local LDAP values and optionally enable Keycloak:

```shell
cp scripts/argocd-ldap.env.example.sh scripts/argocd-ldap.env.sh
vi scripts/argocd-ldap.env.sh

set -a
. ./scripts/argocd-ldap.env.sh
set +a

./scripts/configure-argocd-ldap.sh
```

Do not commit `scripts/argocd-ldap.env.sh`.

To enable Keycloak login, set these values before running the script:

```shell
export KEYCLOAK_ENABLED="true"
export KEYCLOAK_ISSUER="https://keycloak.k3s.dgkim.net/realms/YOUR_REALM"
export KEYCLOAK_CLIENT_ID="argocd"
export KEYCLOAK_CLIENT_SECRET="..."
export KEYCLOAK_ADMIN_GROUP="argocd-admins"
```

The Keycloak client redirect URI for Argo CD's bundled Dex server should be:

```text
https://argocd.k3s.dgkim.net/api/dex/callback
```

The script creates or updates:

```text
argocd/argocd-cm
argocd/argocd-rbac-cm
```

When Keycloak is enabled, it also patches:

```text
argocd/argocd-secret
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

Use the `LDAP` or `Keycloak` login option. Members of the configured LDAP or
Keycloak admin group receive Argo CD admin permissions. Other users receive
read-only permissions.
