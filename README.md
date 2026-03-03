# Radarr Helm Chart

Baseline Helm chart for [Radarr](https://radarr.video) (movie collection manager). Uses the [bjw-s app-template](https://github.com/bjw-s/app-template) with PostgreSQL and 1Password items.

## Subcharts

| Subchart | Source | Values prefix | Description |
|----------|--------|---------------|-------------|
| **radarr** (app-template) | [bjw-s helm-charts](https://github.com/bjw-s/helm-charts) | `radarr.*` | App template: controllers, persistence, ingress, env. |
| **postgresql** | [Bitnami](https://github.com/bitnami/charts) | `postgresql.*` | Embedded PostgreSQL (optional; `postgresql.enabled`). |
| **onepassworditem** | [expectedbehaviors/OnePasswordItem-helm](https://github.com/expectedbehaviors/OnePasswordItem-helm) | `onepassworditem.*` | Optional secrets sync. |

## PostgreSQL options

| Option | Toggle | Default | Description |
|--------|--------|---------|-------------|
| **Bitnami PostgreSQL** | `postgresql.enabled` | `true` | Embedded Bitnami subchart. Set `false` when using operator or external DB. |
| **CloudNativePG operator** | `postgresqlOperator.enabled` | `false` | Creates a `PostgresCluster` CRD. Requires CloudNativePG operator. Set `postgresql.enabled: false` when enabled. |
| **External DB** | Both `false` | — | Use `externalSecrets.configXml.postgresHost` (and credentials) to point at your own PostgreSQL. |

When using `postgresqlOperator`, set `postgresqlOperator.bootstrap.existingSecret` to a Secret with `password` key (e.g. from ExternalSecret). The cluster service will be `{{ postgresqlOperator.clusterName }}-rw.{{ Release.Namespace }}.svc.cluster.local`.

## ExternalSecrets (config.xml)

When `externalSecrets.enabled: true`, the chart creates an ExternalSecret that syncs `config.xml` from 1Password. The secret includes `api_key` and postgres credentials. Requires:

- 1Password item (e.g. `radarr`) with `api_key`
- Postgres credentials item (e.g. `radarr-postgresql-credentials`) with `password`

Defaults:

- `externalSecrets.enabled: false` — config.xml stays managed by your existing Secret; recommended while you migrate existing PostgreSQL data.
- `externalSecrets.configXml.options.*` — all config.xml options have defaults matching upstream (port, ssl, theme, analytics, etc.).
- `externalSecrets.configXml.postgres.method: bitnami|operator|external|sqlite` — single source of truth for DB mode.
- `externalSecrets.configXml.postgres.*` — DB connection values (`host`, `port`, `user`, `mainDb`, `logDb`) and `credentialsRef`.
- In `sqlite` mode, all `<Postgres*>` tags are omitted from config.xml.

Set `externalSecrets.configXml.postgres.method` to `operator` or `external` as needed. After you have migrated existing data and are ready for ExternalSecrets to own `config.xml`, set `externalSecrets.enabled: true`.

## Recommended resources

- **Official docs:** https://radarr.video/docs/
- **Servarr wiki:** https://wiki.servarr.com/radarr
- **TRaSH Guides (Radarr):** https://trash-guides.info/Radarr/
- **Recyclarr docs:** https://recyclarr.dev/wiki/

## Key values

| Area | Where | What to set |
|------|--------|-------------|
| Ingress | `radarr.ingress.main.hosts` | Host and TLS for your domain. |
| Persistence | `radarr.persistence` | `existingClaim` for media/downloads. |
| PostgreSQL | `postgresql.*` or `postgresqlOperator.*` | Auth, storage, or operator cluster. |
| ExternalSecrets | `externalSecrets.*` | 1Password refs for config.xml. |

## Install

```bash
helm dependency update
helm install radarr . -f my-values.yaml -n radarr --create-namespace
```

From Helm repo:

```bash
helm repo add expectedbehaviors https://expectedbehaviors.github.io/radarr
helm install radarr expectedbehaviors/radarr -f my-values.yaml -n radarr --create-namespace
```

## Render & validation

```bash
helm dependency update . && helm template radarr . -f values.yaml -n radarr
```

## Argo CD

Point your Application at this repo (path: `.`) and pass your values. Namespace typically `radarr`.
