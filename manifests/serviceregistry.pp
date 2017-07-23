class fstep::serviceregistry (
  $component_name           = 'f-tep-serviceregistry',

  $install_path             = '/var/f-tep/serviceregistry',
  $config_file              = '/var/f-tep/serviceregistry/f-tep-serviceregistry.conf',
  $logging_config_file      = '/var/f-tep/serviceregistry/log4j2.xml',
  $properties_file          = '/var/f-tep/serviceregistry/application.properties',

  $service_enable           = true,
  $service_ensure           = 'running',

  # f-tep-serviceregistry application.properties config
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

  ensure_packages(['f-tep-serviceregistry'], {
    ensure => 'latest',
    name   => 'f-tep-serviceregistry',
    tag    => 'fstep',
    notify => Service['f-tep-serviceregistry'],
  })

  file { $config_file:
    ensure  => 'present',
    owner   => $fstep::globals::user,
    group   => $fstep::globals::group,
    content => 'JAVA_HOME=/etc/alternatives/java_sdk
JAVA_OPTS="-DLog4jContextSelector=org.apache.logging.log4j.core.async.AsyncLoggerContextSelector -Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager"'
    ,
    require => Package['f-tep-serviceregistry'],
    notify  => Service['f-tep-serviceregistry'],
  }

  ::fstep::logging::log4j2 { $logging_config_file:
    fstep_component => $component_name,
    require        => Package['f-tep-serviceregistry'],
    notify         => Service['f-tep-serviceregistry'],
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
    require => Package['f-tep-serviceregistry'],
    notify  => Service['f-tep-serviceregistry'],
  }

  service { 'f-tep-serviceregistry':
    ensure     => $service_ensure,
    enable     => $service_enable,
    hasrestart => true,
    hasstatus  => true,
    require    => [Package['f-tep-serviceregistry'], File[$properties_file]],
  }

}
