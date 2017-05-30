class fstep::serviceregistry (
  $component_name           = 'fs-tep-serviceregistry',

  $install_path             = '/var/fs-tep/serviceregistry',
  $config_file              = '/var/fs-tep/serviceregistry/fs-tep-serviceregistry.conf',
  $logging_config_file      = '/var/fs-tep/serviceregistry/log4j2.xml',
  $properties_file          = '/var/fs-tep/serviceregistry/application.properties',

  $service_enable           = true,
  $service_ensure           = 'running',

  # fs-tep-serviceregistry application.properties config
  $application_port         = undef,
  $serviceregistry_user     = undef,
  $serviceregistry_pass     = undef,

  $custom_config_properties = { },
) {

  require ::fstep::globals

  contain ::fstep::common::java
  # User and group are set up by the RPM if not included here
  contain ::fstep::common::user

  $real_application_port = pick($application_port, $fstep::globals::serviceregistry_application_port)
  $real_serviceregistry_user = pick($serviceregistry_user, $fstep::globals::serviceregistry_user)
  $real_serviceregistry_pass = pick($serviceregistry_pass, $fstep::globals::serviceregistry_pass)

  # JDK is necessary to compile service stubs
  ensure_packages(['java-1.8.0-openjdk-devel'])

  ensure_packages(['fs-tep-serviceregistry'], {
    ensure => 'latest',
    name   => 'fs-tep-serviceregistry',
    tag    => 'fstep',
    notify => Service['fs-tep-serviceregistry'],
  })

  file { $config_file:
    ensure  => 'present',
    owner   => $fstep::globals::user,
    group   => $fstep::globals::group,
    content => 'JAVA_HOME=/etc/alternatives/java_sdk
JAVA_OPTS="-DLog4jContextSelector=org.apache.logging.log4j.core.async.AsyncLoggerContextSelector -Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager"'
    ,
    require => Package['fs-tep-serviceregistry'],
    notify  => Service['fs-tep-serviceregistry'],
  }

  ::fstep::logging::log4j2 { $logging_config_file:
    fstep_component => $component_name,
    require        => Package['fs-tep-serviceregistry'],
    notify         => Service['fs-tep-serviceregistry'],
  }

  file { $properties_file:
    ensure  => 'present',
    owner   => $fstep::globals::user,
    group   => $fstep::globals::group,
    content => epp('fstep/serviceregistry/application.properties.epp', {
      'logging_config_file'  => $logging_config_file,
      'server_port'          => $real_application_port,
      'serviceregistry_user' => $real_serviceregistry_user,
      'serviceregistry_pass' => $real_serviceregistry_pass,
      'custom_properties'    => $custom_config_properties,
    }),
    require => Package['fs-tep-serviceregistry'],
    notify  => Service['fs-tep-serviceregistry'],
  }

  service { 'fs-tep-serviceregistry':
    ensure     => $service_ensure,
    enable     => $service_enable,
    hasrestart => true,
    hasstatus  => true,
    require    => [Package['fs-tep-serviceregistry'], File[$properties_file]],
  }

}
