

define clgxutil::nexus_s3::nexus_file (
  Enum['present', 'absent'] $ensure    = present,
  String            $nexus_s3_bucket   = $clgxutil::nexus_s3::nexus_s3_bucket,
  String            $nexus_s3_prefix   = $clgxutil::nexus_s3::nexus_s3_prefix,
  String            $nexus_repository  = '',
  String            $nexus_group       = '',
  String            $nexus_artifact    = '',
  String            $nexus_version     = '',
  String            $nexus_extension   = '',
  Optional[String]  $username        = undef,
  Optional[String]  $password        = undef,
  Optional[String]  $user            = undef,
  Optional[String]  $owner           = undef,
  Optional[String]  $group           = undef,
  Optional[String]  $mode            = undef,
  Optional[Boolean] $extract         = undef,
  Optional[String]  $extract_path    = undef,
  Optional[String]  $extract_flags   = undef,
  Optional[String]  $extract_command = undef,
  Optional[String]  $creates         = undef,
  Optional[Boolean] $cleanup         = undef,
  Optional[String]  $proxy_server    = undef,
  Optional[String]  $proxy_type      = undef,
  Optional[Boolean] $allow_insecure  = undef,
) {

  $group_path = regsubst($nexus_group, '\.', '/', 'G')
  $s3_uri_parts = [
    "s3://${nexus_s3_bucket}/${nexus_s3_prefix}${nexus_repository}",
    $group_path,
    $nexus_artifact,
    $nexus_version,
    "${nexus_artifact}-${nexus_version}.${nexus_extension}"
  ]
  $s3_uri = join($s3_uri_parts, '/')

  archive {$title:
    ensure          => $ensure,
    source          => $s3_uri,
    username        => $username,
    password        => $password,
    extract         => $extract,
    extract_path    => $extract_path,
    extract_flags   => $extract_flags,
    extract_command => $extract_command,
    user            => $user,
    group           => $group,
    creates         => $creates,
    cleanup         => $cleanup,
    proxy_server    => $proxy_server,
    proxy_type      => $proxy_type,
    allow_insecure  => $allow_insecure,
  }


}
