class fstep::webapp (
  $app_path        = '/var/www/html/f-tep',
  $app_config_file = 'scripts/fstepConfig.js',

  $fstep_url        = undef,
  $api_url         = undef,
  $api_v2_url      = undef,
  $sso_url         = 'https://eo-sso-idp.evo-pdgs.com',
  $mapbox_token    = 'pk.eyJ1IjoidmFuemV0dGVucCIsImEiOiJjaXZiZTM3Y2owMDdqMnVwa2E1N2VsNGJnIn0.A9BNRSTYajN0fFaVdJIpzQ',
) {

  require ::fstep::globals

  contain ::fstep::common::apache

  ensure_packages(['f-tep-portal'], {
    ensure => 'latest',
    name   => 'f-tep-portal',
    tag    => 'fstep',
  })

  $real_fstep_url = pick($fstep_url, $fstep::globals::base_url)
  $real_api_url = pick($api_url, "${fstep::globals::base_url}/secure/api/v1.0")
  $real_api_v2_url = pick($api_v2_url, "${$fstep::globals::base_url}/secure/api/v2.0")

  file { "${app_path}/${app_config_file}":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    content => epp('fstep/webapp/fstepConfig.js.epp', {
      'fstep_url'     => $real_fstep_url,
      'api_url'      => $real_api_url,
      'api_v2_url'   => $real_api_v2_url,
      'sso_url'      => $sso_url,
      'mapbox_token' => $mapbox_token,
    }),
    require => Package['f-tep-portal'],
  }

  ::apache::vhost { 'fstep-webapp':
    port       => '80',
    servername => 'fstep-webapp',
    docroot    => $app_path,
  }

}
