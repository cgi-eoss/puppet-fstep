class fstep::drupal::apache (
  $site_path
) {

  require ::fstep::globals

  contain ::fstep::common::apache

  include ::apache::mod::proxy_http
  include ::apache::mod::rewrite
  include ::apache::mod::proxy

  # apache::mod::proxy_fcgi does not include the package on CentOS 6
  case $::operatingsystemmajrelease {
    '6': { ensure_resource('apache::mod', 'proxy_fcgi', { package => 'mod_proxy_fcgi', require => Class['apache::mod::proxy'] }) }
    default: { include ::apache::mod::proxy_fcgi }
  }

  ::apache::vhost { 'fstep-drupal':
    port             => '80',
    servername       => 'fstep-drupal',
    docroot          => "${site_path}",
    override         => ['All'],
    directoryindex   => '/index.php index.php',
    proxy_pass_match => [
      {
        'path' => '^/(.*\.php(/.*)?)$',
        'url'  => "fcgi://127.0.0.1:9000${site_path}/\$1"
      }
    ],
    rewrites         => [
      { rewrite_rule => [
        '^/api/(.*) /api.php?q=api/$1 [L,PT,QSA]',
        '^/secure/api/(.*) /api.php?q=api/$1 [L,PT,QSA]'
      ] },
    ]
  }

}
