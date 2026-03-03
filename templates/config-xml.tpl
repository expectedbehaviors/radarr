{{- define "radarr_config_xml_content" -}}
{{- /*
  Radarr config.xml content for ExternalSecret. Placeholders __API_KEY__, __POSTGRES_PASSWORD__
  are replaced in externalSecrets.yaml with ESO v2 template syntax.
  Postgres host/user/db come from .Values.externalSecrets.configXml (Helm).
*/ -}}
{{- $e := .Values.externalSecrets.configXml | default dict }}
<Config>
  <LogLevel>Info</LogLevel>
  <Port>7878</Port>
  <UrlBase></UrlBase>
  <BindAddress>*</BindAddress>
  <SslPort>7878</SslPort>
  <EnableSsl>False</EnableSsl>
  <ApiKey>__API_KEY__</ApiKey>
  <AuthenticationMethod>Basic</AuthenticationMethod>
  <Branch>nightly</Branch>
  <LaunchBrowser>False</LaunchBrowser>
  <UpdateMechanism>Docker</UpdateMechanism>
  <AnalyticsEnabled>False</AnalyticsEnabled>
  <UpdateAutomatically>True</UpdateAutomatically>
  <InstanceName>Radarr</InstanceName>
  <PostgresUser>{{ $e.postgresUser | default "postgres" }}</PostgresUser>
  <PostgresPassword>__POSTGRES_PASSWORD__</PostgresPassword>
  <PostgresPort>{{ $e.postgresPort | default "5432" }}</PostgresPort>
  <PostgresHost>{{ $e.postgresHost | default "postgresql-rw.postgresql.svc.cluster.local" }}</PostgresHost>
  <PostgresMainDb>{{ $e.postgresMainDb | default "radarr-main" }}</PostgresMainDb>
  <PostgresLogDb>{{ $e.postgresLogDb | default "radarr-log" }}</PostgresLogDb>
</Config>
{{- end -}}
