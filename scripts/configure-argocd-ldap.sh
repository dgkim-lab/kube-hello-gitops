#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"

argocd_url="${ARGOCD_URL:-https://argocd.k3s-test.dgkim.net}"
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
keycloak_enabled="${KEYCLOAK_ENABLED:-false}"
keycloak_issuer="${KEYCLOAK_ISSUER:-}"
keycloak_client_id="${KEYCLOAK_CLIENT_ID:-argocd}"
keycloak_client_secret="${KEYCLOAK_CLIENT_SECRET:-}"
keycloak_scopes="${KEYCLOAK_SCOPES:-profile,email,groups}"
keycloak_admin_group="${KEYCLOAK_ADMIN_GROUP:-argocd-admins}"

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

case "${keycloak_enabled}" in
  true|false) ;;
  *)
    echo "KEYCLOAK_ENABLED must be true or false" >&2
    exit 1
    ;;
esac

keycloak_connector=""
keycloak_rbac_policy=""

if [[ "${keycloak_enabled}" == "true" ]]; then
  if [[ -z "${keycloak_issuer}" || "${keycloak_issuer}" == *"YOUR_REALM"* ]]; then
    echo "KEYCLOAK_ISSUER must be set to the Keycloak realm issuer URL." >&2
    exit 1
  fi

  if [[ -z "${keycloak_client_secret}" || "${keycloak_client_secret}" == "change-me" ]]; then
    echo "KEYCLOAK_CLIENT_SECRET must be set to the Keycloak client secret." >&2
    exit 1
  fi

  keycloak_scopes_yaml=""
  IFS=',' read -r -a scopes <<< "${keycloak_scopes}"
  for scope in "${scopes[@]}"; do
    scope="${scope#"${scope%%[![:space:]]*}"}"
    scope="${scope%"${scope##*[![:space:]]}"}"
    [[ -z "${scope}" ]] && continue
    if [[ "${scope}" == "openid" ]]; then
      echo "Skipping KEYCLOAK_SCOPES entry 'openid'; Dex requests it automatically." >&2
      continue
    fi
    keycloak_scopes_yaml+="            - ${scope}"$'\n'
  done

  keycloak_scopes_config=""
  if [[ -n "${keycloak_scopes_yaml}" ]]; then
    keycloak_scopes_config=$(cat <<EOF
          scopes:
${keycloak_scopes_yaml%$'\n'}
EOF
)
  fi

  keycloak_connector=$(cat <<EOF
      - type: oidc
        id: keycloak
        name: Keycloak
        config:
          issuer: ${keycloak_issuer}
          clientID: ${keycloak_client_id}
          clientSecret: \$dex.keycloak.clientSecret
${keycloak_scopes_config}
          insecureEnableGroups: true
EOF
)

  keycloak_rbac_policy="    g, ${keycloak_admin_group}, role:admin"
fi

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

if [[ "${keycloak_enabled}" == "true" ]]; then
  kubectl -n "${NAMESPACE}" get secret argocd-secret >/dev/null 2>&1 \
    || kubectl -n "${NAMESPACE}" create secret generic argocd-secret
  encoded_keycloak_client_secret="$(printf "%s" "${keycloak_client_secret}" | base64 | tr -d '\n')"
  kubectl -n "${NAMESPACE}" patch secret argocd-secret --type merge \
    -p "{\"data\":{\"dex.keycloak.clientSecret\":\"${encoded_keycloak_client_secret}\"}}"
fi

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
${keycloak_connector}
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
${keycloak_rbac_policy}
  policy.default: role:readonly
  scopes: "[groups]"
EOF

if [[ "${keycloak_enabled}" == "true" ]]; then
  echo "Created or updated Argo CD LDAP and Keycloak config in namespace ${NAMESPACE}."
else
  echo "Created or updated Argo CD LDAP config in namespace ${NAMESPACE}."
fi
