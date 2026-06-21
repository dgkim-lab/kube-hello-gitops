#!/usr/bin/env bash

# Argo CD externally reachable URL.
export ARGOCD_URL="https://argocd.k3s-test.dgkim.net"

# LDAP endpoint reachable from the argocd-dex-server pod.
export LDAP_HOST="ldap.dgkim.net:389"

# Set to false for LDAPS or STARTTLS-capable secure LDAP configuration.
export LDAP_INSECURE_NO_SSL="true"

# User search settings. These values are environment-specific and stay out of Git.
export LDAP_USER_BASE_DN="ou=people,dc=dgkim,dc=net"
export LDAP_USER_FILTER="(objectClass=person)"
export LDAP_USERNAME_ATTR="uid"
export LDAP_USER_ID_ATTR="DN"
export LDAP_EMAIL_ATTR="mail"
export LDAP_NAME_ATTR="cn"

# Group search settings. The default assumes groupOfNames with member=<user DN>.
export LDAP_GROUP_BASE_DN="ou=groups,dc=dgkim,dc=net"
export LDAP_GROUP_FILTER="(objectClass=groupOfNames)"
export LDAP_GROUP_MEMBER_ATTR="member"
export LDAP_GROUP_NAME_ATTR="cn"

# LDAP group granted Argo CD admin rights.
export ARGOCD_ADMIN_GROUP="argocd-admins"

# Optional Keycloak login through Argo CD's bundled Dex server.
# Keep disabled until the Keycloak realm, client, redirect URI, and group mapper
# are ready.
export KEYCLOAK_ENABLED="false"

# Keycloak realm issuer URL. Example:
# https://keycloak.k3s-test.dgkim.net/realms/master
export KEYCLOAK_ISSUER="https://keycloak.k3s-test.dgkim.net/realms/YOUR_REALM"

# OpenID Connect client created in Keycloak for Argo CD / Dex.
export KEYCLOAK_CLIENT_ID="argocd"

# Secret for the confidential Keycloak client.
# Do not commit a real secret.
export KEYCLOAK_CLIENT_SECRET="change-me"

# Additional scopes requested from Keycloak. Dex already requests openid, so do
# not include it here. Keep groups if Argo CD RBAC should use Keycloak group
# membership.
export KEYCLOAK_SCOPES="profile,email,groups"

# Keycloak group granted Argo CD admin rights.
# If Keycloak emits full group paths, use a value like /argocd-admins.
export KEYCLOAK_ADMIN_GROUP="argocd-admins"
