class fstep::ui (
  $app_path        = '/var/www/html/',
) {

  require ::fstep::globals

  contain ::fstep::common::apache

  ensure_packages(['fs-tep-ui'], {
    ensure => 'latest',
    name   => 'fs-tep-ui',
    tag    => 'fstep',
  })
  
    $directories = [
      {
        'provider'   => 'location',
        'path'       => '/analyst',
		'custom_fragment' => ' RewriteEngine On
		# If an existing asset or directory is requested go to it as it is
		RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} -f [OR]
		RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} -d
		RewriteRule ^ - [L]
		# If the requested resource does not exist, use index.html
		RewriteRule ^ /analyst/index.html'
		}
    ]

  ::apache::vhost { 'fstep-ui':
    port       => '80',
    servername => 'fstep-ui',
    docroot    => $app_path,
    directories => $directories
  }

}

