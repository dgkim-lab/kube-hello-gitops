#!/usr/bin/env bash

# Argo CD externally reachable URL.
export ARGOCD_URL="https://argocd.k3s.dgkim.net"

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
