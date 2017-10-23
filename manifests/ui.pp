class fstep::ui (
  $app_path        = '/var/www/html/analyst',
) {

  require ::fstep::globals

  contain ::fstep::common::apache

  ensure_packages(['fs-tep-ui'], {
    ensure => 'latest',
    name   => 'fs-tep-ui',
    tag    => 'fstep',
  })

  ::apache::vhost { 'fstep-ui':
    port       => '80',
    servername => 'fstep-ui',
    docroot    => $app_path,
  }

}
