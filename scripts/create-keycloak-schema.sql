-- Manual bootstrap SQL for the shared dev PostgreSQL server.
-- Replace the password before running this against the dev-db PostgreSQL server.
CREATE USER keycloak WITH PASSWORD 'replace-me';
CREATE SCHEMA keycloak AUTHORIZATION keycloak;
