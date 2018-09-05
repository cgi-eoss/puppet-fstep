class fstep::dockerregistry (
  $group                  = 'hrb-admin',
  $user                   = 'hrb-admin',
  $user_home              = '/home/hrb-admin',
  $harbor_home            = '/opt/harbor',
  $config_file            = '/opt/harbor/harbor.cfg',
  $docker_ce_repo_url     = 'https://download.docker.com/linux/centos/docker-ce.repo',
  $docker_ce_version      = '17.12.0.ce',
  $docker_compose_version = '1.18.0',
  $docker_compose_file    = 'docker-compose',
  $harbor_version         = '1.3.0',
  $harbor_archive         = 'harbor-offline-installer-v1.3.0.tgz',
  # # the following var should be with one or both: --with-clair , --with-notary
  $install_opts           = '--with-clair',
  $hostname               = "fstep-dockerregistry.local",
  $ui_url_protocol        = "http",
  $db_password            = "registrypass",
  $ssl_cert_path          = "/data/cert/",
  $ssl_cert_key           = "/data/key",
  $clair_db_password      = "clairpass",
  $harbor_admin_password  = "harborpass") {
  require ::fstep::globals

  group { $group: ensure => present, }

  user { $user:
    ensure     => present,
    gid        => $group,
    managehome => true,
    home       => $user_home,
    shell      => '/bin/bash',
    require    => Group[$group],
  }

  ensure_packages(['yum', 'yum-utils', 'device-mapper-persistent-data', "python.$architecture", 'lvm2', 'tar', 'curl', 'openssl'])

  exec { 'yum-update': command => '/bin/yum makecache fast', }

  package { 'docker': ensure => absent, }

  package { 'docker-common': ensure => absent, }
  
  package { 'docker-engine': ensure => absent, }

  exec { 'docker-ce-repo-add': command => "/bin/yum-config-manager --add-repo $docker_ce_repo_url" }

  package { 'docker-ce':
    ensure  => installed,
    require => Exec['docker-ce-repo-add'],
  }

  service { 'docker':
    ensure  => running,
    enable  => true,
    require => Package['docker-ce'],
  }

  exec{'retrieve_docker_compose':
  command => "/usr/bin/wget -q https://github.com/docker/compose/releases/download/$docker_compose_version/docker-compose-Linux-$architecture -O /usr/local/sbin/docker-compose-Linux-$architecture",
  creates => "/usr/local/bin/docker-compose-Linux-$architecture",
  }

  file { "/usr/local/sbin/docker-compose-Linux-$architecture":
    mode    => '0755',
    require => Exec['retrieve_docker_compose'],
  }
  
  exec{'retrieve_harbor':
  command => "/usr/bin/wget -q https://storage.googleapis.com/harbor-releases/$harbor_archive -O ${user_home}/$harbor_archive",
  creates => "${user_home}/$harbor_archive",
  }
  
  file { "${user_home}/$harbor_archive":
   owner => $user
  }

  file { $harbor_home:
    ensure  => directory,
    mode    => '0750',
    owner   => $user,
    require => User[$user],
  }
  
  exec { 'unzip_harbor':
    command => "/bin/tar xzf ${user_home}/$harbor_archive --strip 1 -C $harbor_home",
    require      => [User[$user], File["${user_home}/$harbor_archive"], File["$harbor_home"]],
  }

  file { $config_file:
    ensure  => present,
    content => epp('fstep/harbor/harbor.cfg.epp', {
      'hostname'              => $hostname,
      'ui_url_protocol'       => $ui_url_protocol,
      'db_password'           => $db_password,
      'ssl_cert_path'         => $ssl_cert_path,
      'ssl_cert_key'          => $ssl_cert_key,
      'clair_db_password'     => $clair_db_password,
      'harbor_admin_password' => $harbor_admin_password
    }
    ),
    require => Exec['unzip_harbor'],
  }
  
  exec { 'harbor-install':
    command => "$harbor_home/install.sh $install_opts",
    require => File["$config_file"],
  }

}
