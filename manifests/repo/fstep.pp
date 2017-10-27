# FS-TEP package repository
class fstep::repo::fstep {
  ensure_resource(yumrepo, 'fstep', {
    ensure          => 'present',
    descr           => 'FS-TEP',
    baseurl         => $fstep::repo::location,
    enabled         => 1,
    gpgcheck        => 0,
    metadata_expire => '15m',
  })
}