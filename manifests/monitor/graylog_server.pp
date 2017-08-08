class fstep::monitor::graylog_server (
  $db_secret    = undef,
  $db_sha256    = undef,
  $db_bind_ip   = '127.0.0.1',

  $listen_host  = '0.0.0.0',
  $listen_port  = undef,
  $context_path = undef,
) {

  require ::epel

  contain ::fstep::common::java

  $real_db_secret = pick($db_secret, $fstep::globals::graylog_secret)
  $real_db_sha256 = pick($db_sha256, $fstep::globals::graylog_sha256)
  $real_listen_port = pick($listen_port, $fstep::globals::graylog_port)
  $real_context_path = pick($context_path, $fstep::globals::graylog_context_path)

  class { ::mongodb::globals:
    manage_package_repo => true,
  } ->
    class { ::mongodb::server:
      bind_ip => [$db_bind_ip],
    }

  class { ::elasticsearch:
    java_install => false,
    manage_repo  => true,
    version      => '5.5.1',
    repo_version => '5.x',
  } ->
    ::elasticsearch::instance { 'graylog':
      config => {
        'cluster.name' => 'graylog',
        'network.host' => $db_bind_ip,
      }
    }

  class { ::graylog::repository:
    version => '2.3'
  } ->
    class { ::graylog::server:
      package_version => '2.3.0-7',
      config          => {
        password_secret          => $real_db_secret, # Fill in your password secret
        root_password_sha2       => $real_db_sha256, # Fill in your root password hash
        web_listen_uri           => "http://${listen_host}:${real_listen_port}${real_context_path}/",
        rest_listen_uri          => "http://${listen_host}:${real_listen_port}${real_context_path}/api/",
        usage_statistics_enabled => false,
      }
    }

}
