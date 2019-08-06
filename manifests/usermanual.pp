class fstep::usermanual (
  $app_path        = '/var/www/html/',
) {

  require ::fstep::globals

  contain ::fstep::common::apache

  ensure_packages(['fs-tep-user-manual'], {
    ensure => 'latest',
    name   => 'fs-tep-user-manual',
    tag    => 'fstep',
  })
  
    $directories = [
      {
        'provider'   => 'location',
        'path'       => '/user-manual'
	  }
    ]

  ::apache::vhost { 'fstep-user-manual':
    port       => '80',
    servername => 'fstep-user-manual',
    docroot    => $app_path,
    directories => $directories
  }

}

