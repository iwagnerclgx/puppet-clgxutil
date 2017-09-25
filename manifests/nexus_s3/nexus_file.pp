

define clgxutil::nexus_s3::nexus_file (
  $nexus_s3_bucket   = $clgxutil::nexus_s3::nexus_s3_bucket,
  $nexus_s3_prefix   = $clgxutil::nexus_s3::nexus_s3_prefix,
  $nexus_repository  = '',
  $nexus_group       = '',
  $nexus_artifact    = '',
  $nexus_version     = '',
  $nexus_extension   = '',


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
    ensure => present,
    source => $s3_uri,
  }

}
