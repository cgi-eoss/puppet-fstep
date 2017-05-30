class fstep::common::datadir (
  $data_basedir = '/data'
) {
  require ::fstep::common::user

  # TODO Use nfs server for $data_basedir
  file { $data_basedir:
    ensure  => directory,
    owner   => 'fstep',
    group   => 'fstep',
    mode    => '755',
    recurse => false,
  }
}