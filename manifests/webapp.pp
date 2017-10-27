class fstep::webapp (
  $app_path        = '/var/www/html/fs-tep',
  $app_config_file = 'scripts/fstepConfig.js',

  $fstep_url        = undef,
  $api_url          = undef,
  $api_v2_url       = undef,
  $fstep_portal_url = undef,
  $analyst_url      = undef,
  $sso_url          = 'https://eo-sso-idp.evo-pdgs.com',
  $mapbox_token     = 'pk.eyJ1IjoidmFuemV0dGVucCIsImEiOiJjaXZiZTM3Y2owMDdqMnVwa2E1N2VsNGJnIn0.A9BNRSTYajN0fFaVdJIpzQ',
) {

  require ::fstep::globals

  contain ::fstep::common::apache

  ensure_packages(['fs-tep-portal'], {
    ensure => 'latest',
    name   => 'fs-tep-portal',
    tag    => 'fstep',
  })

  $real_fstep_url = pick($fstep_url, $fstep::globals::base_url)
  $real_api_url = pick($api_url, "${fstep::globals::base_url}/secure/api/v1.0")
  $real_api_v2_url = pick($api_v2_url, "${$fstep::globals::base_url}/secure/api/v2.0")
  $real_portal_url = pick($fstep_portal_url, $fstep::globals::drupal_url)
  $real_analyst_url = pick($analyst_url, "${fstep::globals::base_url}/${fstep::globals::context_path_analyst}")

  file { "${app_path}/${app_config_file}":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    content => epp('fstep/webapp/fstepConfig.js.epp', {
      'fstep_url'        => $real_fstep_url,
      'api_url'          => $real_api_url,
      'api_v2_url'       => $real_api_v2_url,
      'sso_url'          => $sso_url,
      'fstep_portal_url' => $real_portal_url,
      'analyst_url'      => $real_analyst_url,
      'mapbox_token'     => $mapbox_token,
    }),
    require => Package['fs-tep-portal'],
  }

  ::apache::vhost { 'fstep-webapp':
    port       => '80',
    servername => 'fstep-webapp',
    docroot    => $app_path,
  }

}
