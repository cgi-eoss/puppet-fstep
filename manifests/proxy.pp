# Configure the gateway to the FS-TEP services, reverse-proxying to nodes implementing the other classes
class fstep::proxy (
  $vhost_name             = 'fstep-proxy',

  $enable_ssl             = false,
  $enable_sso             = false,

  $context_path_geoserver = undef,
  $context_path_resto     = undef,
  $context_path_webapp    = undef,
  $context_path_wps       = undef,
  $context_path_api_v2    = undef,
  $context_path_monitor   = undef,
  $context_path_logs      = undef,
  $context_path_eureka    = undef,
  $context_path_gui       = undef,

  $tls_cert_path          = '/etc/pki/tls/certs/fstep_portal.crt',
  $tls_chain_path         = '/etc/pki/tls/certs/fstep_portal.chain.crt',
  $tls_key_path           = '/etc/pki/tls/private/fstep_portal.key',
  $tls_cert               = undef,
  $tls_chain              = undef,
  $tls_key                = undef,
) {

  require ::fstep::globals

  contain ::fstep::common::apache

  include ::apache::mod::headers
  include ::apache::mod::proxy
  include ::apache::mod::rewrite

  $default_proxy_config = {
    docroot    => '/var/www/html',
    vhost_name => '_default_', # The default landing site should always be Drupal
    proxy_dest => 'http://fstep-drupal', # Drupal is always mounted at the base_url
    rewrites   => [
      {
        rewrite_rule => ['^/app$ /app/ [R]']
      }
    ]
  }

  $real_context_path_geoserver = pick($context_path_geoserver, $fstep::globals::context_path_geoserver)
  $real_context_path_resto = pick($context_path_resto, $fstep::globals::context_path_resto)
  $real_context_path_webapp = pick($context_path_webapp, $fstep::globals::context_path_webapp)
  $real_context_path_wps = pick($context_path_wps, $fstep::globals::context_path_wps)
  $real_context_path_api_v2 = pick($context_path_api_v2, $fstep::globals::context_path_api_v2)
  $real_context_path_monitor = pick($context_path_monitor, $fstep::globals::context_path_monitor)
  $real_context_path_logs = pick($context_path_logs, $fstep::globals::context_path_logs)
  $real_context_path_eureka = pick($context_path_eureka, $fstep::globals::context_path_eureka)

  # Directory/Location directives - cannot be an empty array...
  $default_directories = [
    {
      'provider'        => 'location',
      'path'            => $real_context_path_logs,
      'custom_fragment' =>
      "RequestHeader set X-Graylog-Server-URL \"${fstep::globals::base_url}${fstep::globals::graylog_api_path}\""
    }
  ]

  # Reverse proxied paths
  $default_proxy_pass = [
    {
      'path'   => $real_context_path_geoserver,
      'url'    => "http://${fstep::globals::geoserver_hostname}:${fstep::globals::geoserver_port}${real_context_path_geoserver}",
      'params' => { 'retry' => '0' }
    },
    {
      'path'   => $real_context_path_resto,
      'url'    => "http://${fstep::globals::resto_hostname}",
      'params' => { 'retry' => '0' }
    },
    {
      'path'   => $real_context_path_webapp,
      'url'    => "http://${fstep::globals::webapp_hostname}",
      'params' => { 'retry' => '0' }
    },
    {
      'path'   => $real_context_path_wps,
      'url'    => "http://${fstep::globals::wps_hostname}",
      'params' => { 'retry' => '0' }
    },
    {
      'path'   => $real_context_path_api_v2,
      'url'    => "http://${fstep::globals::server_hostname}:${fstep::globals::server_application_port}${real_context_path_api_v2}",
      'params' => { 'retry' => '0' }
    },
    {
      'path'   => $real_context_path_monitor,
      'url'    => "http://${fstep::globals::monitor_hostname}:${fstep::globals::grafana_port}",
      'params' => { 'retry' => '0' }
    },
    {
      'path'   => $real_context_path_logs,
      'url'    => "http://${fstep::globals::monitor_hostname}:${fstep::globals::graylog_port}${fstep::globals::graylog_context_path}",
      'params' => { 'retry' => '0' }
    },
    {
      'path'   => $real_context_path_eureka,
      'url'    => "http://${fstep::globals::server_hostname}:${fstep::globals::serviceregistry_application_port}/eureka",
      'params' => { 'retry' => '0' }
    }
  ]

  $default_proxy_pass_match = [
    {
      'path'   => '^/gui/(.*)$',
      'url'    => "http://${fstep::globals::default_gui_hostname}\$1",
      'params' => { 'retry' => '0' }
    }
  ]

  if $enable_sso {
    unless ($tls_cert and $tls_key) {
      fail("fstep::proxy requres \$tls_cert and \$tls_key to be set if \$enable_sso is true")
    }
    contain ::fstep::proxy::shibboleth

    # Add the /Shibboleth.sso SP callback location, enable the minimal support for the root, and add secured paths
    $directories = concat([
      {
        'provider'   => 'location',
        'path'       => '/Shibboleth.sso',
        'sethandler' => 'shib'
      },
      {
        'provider'              => 'location',
        'path'                  => '/',
        'auth_type'             => 'shibboleth',
        'shib_use_headers'      => 'On',
        'shib_request_settings' => { 'requireSession' => '0' },
        'custom_fragment'       => $::operatingsystemmajrelease ? {
          '6'     => 'ShibCompatWith24 On',
          default => ''
        },
        'auth_require'          => 'shibboleth',
      },
      {
        'provider'              => 'location',
        'path'                  => $real_context_path_webapp,
        'auth_type'             => 'shibboleth',
        'shib_use_headers'      => 'On',
        'shib_request_settings' => { 'requireSession' => '1' },
        'custom_fragment'       => $::operatingsystemmajrelease ? {
          '6'     => 'ShibCompatWith24 On',
          default => ''
        },
        'auth_require'          => 'valid-user',
      },
      {
        'provider'              => 'location',
        'path'                  => '/secure',
        'auth_type'             => 'shibboleth',
        'shib_use_headers'      => 'On',
        'shib_request_settings' => { 'requireSession' => '1' },
        'custom_fragment'       => $::operatingsystemmajrelease ? {
          '6'     => 'ShibCompatWith24 On',
          default => ''
        },
        'auth_require'          => 'valid-user',
      }
    ], $default_directories)

    # Insert the callback location at the start of the reverse proxy list
    $proxy_pass = concat([{
      'path'         => '/Shibboleth.sso',
      'url'          => '!',
      'reverse_urls' => [],
      'params'       => { 'retry' => '0' }
    }], $default_proxy_pass)
    $proxy_pass_match = $default_proxy_pass_match
  } else {
    $directories = $default_directories
    $proxy_pass = $default_proxy_pass
    $proxy_pass_match = $default_proxy_pass_match
  }

  if $enable_ssl {
    unless ($tls_cert and $tls_key) {
      fail("fstep::proxy requres \$tls_cert and \$tls_key to be set if \$enable_ssl is true")
    }

    file { $tls_cert_path:
      ensure  => present,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => $tls_cert,
    }

    if $tls_chain {
      file { $tls_chain_path:
        ensure  => present,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        content => $tls_chain,
      }
      $real_tls_chain_path = $tls_chain_path
    } else {
      $real_tls_chain_path = undef
    }

    file { $tls_key_path:
      ensure  => present,
      mode    => '0600',
      owner   => 'root',
      group   => 'root',
      content => $tls_key,
    }

    apache::vhost { "redirect ${vhost_name} non-ssl":
      servername      => $vhost_name,
      port            => '80',
      docroot         => '/var/www/redirect',
      redirect_status => 'permanent',
      redirect_dest   => "https://${vhost_name}/"
    }
    apache::vhost { $vhost_name:
      servername       => $vhost_name,
      port             => '443',
      ssl              => true,
      ssl_cert         => $tls_cert_path,
      ssl_chain        => $real_tls_chain_path,
      ssl_key          => $tls_key_path,
      default_vhost    => true,
      request_headers  => [
        'set X-Forwarded-Proto "https"'
      ],
      directories      => $directories,
      # default rewrite requested by ESA scan
      rewrites => [
        {
          rewrite_cond => ['%{REQUEST_METHOD} ^(TRACE|TRACK)'],
          rewrite_rule => ['.* - [F]']
        }
      ],
      proxy_pass       => $proxy_pass,
      proxy_pass_match => $proxy_pass_match,
      *                => $default_proxy_config,
    }
  } else {
    apache::vhost { $vhost_name:
      port             => '80',
      default_vhost    => true,
      directories      => $directories,
      # default rewrite requested by ESA scan
      rewrites => [
        {
          rewrite_cond => ['%{REQUEST_METHOD} ^(TRACE|TRACK)'],
          rewrite_rule => ['.* - [F]']
        }
      ],
      proxy_pass       => $proxy_pass,
      proxy_pass_match => $proxy_pass_match,
      *                => $default_proxy_config
    }
  }

}
