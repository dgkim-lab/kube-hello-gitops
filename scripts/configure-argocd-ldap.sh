#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"

argocd_url="${ARGOCD_URL:-https://argocd.k3s.dgkim.net}"
ldap_host="${LDAP_HOST:-ldap.dgkim.net:389}"
ldap_insecure_no_ssl="${LDAP_INSECURE_NO_SSL:-true}"
ldap_user_base_dn="${LDAP_USER_BASE_DN:-ou=people,dc=dgkim,dc=net}"
ldap_user_filter="${LDAP_USER_FILTER:-(objectClass=person)}"
ldap_username_attr="${LDAP_USERNAME_ATTR:-uid}"
ldap_user_id_attr="${LDAP_USER_ID_ATTR:-DN}"
ldap_email_attr="${LDAP_EMAIL_ATTR:-mail}"
ldap_name_attr="${LDAP_NAME_ATTR:-cn}"
ldap_group_base_dn="${LDAP_GROUP_BASE_DN:-ou=groups,dc=dgkim,dc=net}"
ldap_group_filter="${LDAP_GROUP_FILTER:-(objectClass=groupOfNames)}"
ldap_group_member_attr="${LDAP_GROUP_MEMBER_ATTR:-member}"
ldap_group_name_attr="${LDAP_GROUP_NAME_ATTR:-cn}"
argocd_admin_group="${ARGOCD_ADMIN_GROUP:-argocd-admins}"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required but not installed." >&2
  exit 1
fi

case "${ldap_insecure_no_ssl}" in
  true|false) ;;
  *)
    echo "LDAP_INSECURE_NO_SSL must be true or false" >&2
    exit 1
    ;;
esac

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: ${NAMESPACE}
data:
  url: ${argocd_url}
  dex.config: |
    connectors:
      - type: ldap
        id: ldap
        name: LDAP
        config:
          host: ${ldap_host}
          insecureNoSSL: ${ldap_insecure_no_ssl}
          userSearch:
            baseDN: ${ldap_user_base_dn}
            filter: "${ldap_user_filter}"
            username: ${ldap_username_attr}
            idAttr: ${ldap_user_id_attr}
            emailAttr: ${ldap_email_attr}
            nameAttr: ${ldap_name_attr}
          groupSearch:
            baseDN: ${ldap_group_base_dn}
            filter: "${ldap_group_filter}"
            userMatchers:
              - userAttr: DN
                groupAttr: ${ldap_group_member_attr}
            nameAttr: ${ldap_group_name_attr}
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: ${NAMESPACE}
data:
  policy.csv: |
    g, ${argocd_admin_group}, role:admin
  policy.default: role:readonly
  scopes: "[groups]"
EOF

echo "Created or updated Argo CD LDAP config in namespace ${NAMESPACE}."
