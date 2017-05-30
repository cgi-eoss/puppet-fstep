class fstep::zoomanager (
  $component_name           = 'fs-tep-zoomanager',

  $install_path             = '/var/fs-tep/zoomanager',
  $config_file              = '/var/fs-tep/zoomanager/fs-tep-zoomanager.conf',
  $logging_config_file      = '/var/fs-tep/zoomanager/log4j2.xml',
  $properties_file          = '/var/fs-tep/zoomanager/application.properties',

  $service_enable           = true,
  $service_ensure           = 'running',

  # fs-tep-zoomanager application.properties config
  $application_port         = undef,
  $grpc_port                = undef,

  $serviceregistry_user     = undef,
  $serviceregistry_pass     = undef,
  $serviceregistry_host     = undef,
  $serviceregistry_port     = undef,
  $serviceregistry_url      = undef,

  $zcfg_path                = '/var/www/cgi-bin',
  $classpath_jar_files      = [],
  $services_stub_jar        = '/var/www/cgi-bin/jars/fs-tep-services.jar',

  $custom_config_properties = { },
) {

  require ::fstep::globals

  contain ::fstep::common::java
  # User and group are set up by the RPM if not included here
  contain ::fstep::common::user

  $real_application_port = pick($application_port, $fstep::globals::zoomanager_application_port)
  $real_grpc_port = pick($grpc_port, $fstep::globals::zoomanager_grpc_port)

  $real_serviceregistry_user = pick($serviceregistry_user, $fstep::globals::serviceregistry_user)
  $real_serviceregistry_pass = pick($serviceregistry_pass, $fstep::globals::serviceregistry_pass)
  $real_serviceregistry_host = pick($serviceregistry_host, $fstep::globals::server_hostname)
  $real_serviceregistry_port = pick($serviceregistry_port, $fstep::globals::serviceregistry_application_port)
  $serviceregistry_creds = "${real_serviceregistry_user}:${real_serviceregistry_pass}"
  $serviceregistry_server = "${real_serviceregistry_host}:${real_serviceregistry_port}"
  $real_serviceregistry_url = pick($serviceregistry_url,
    "http://${serviceregistry_creds}@${serviceregistry_server}/eureka/")

  # JDK is necessary to compile service stubs
  ensure_packages(['java-1.8.0-openjdk-devel'])

  ensure_packages(['fs-tep-zoomanager'], {
    ensure => 'latest',
    name   => 'fs-tep-zoomanager',
    tag    => 'fstep',
    notify => Service['fs-tep-zoomanager'],
  })

  file { $config_file:
    ensure  => 'present',
    owner   => $fstep::globals::user,
    group   => $fstep::globals::group,
    content => 'JAVA_HOME=/etc/alternatives/java_sdk
JAVA_OPTS="-DLog4jContextSelector=org.apache.logging.log4j.core.async.AsyncLoggerContextSelector -Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager"'
    ,
    require => Package['fs-tep-zoomanager'],
    notify  => Service['fs-tep-zoomanager'],
  }

  ::fstep::logging::log4j2 { $logging_config_file:
    fstep_component => $component_name,
    require        => Package['fs-tep-zoomanager'],
    notify         => Service['fs-tep-zoomanager'],
  }

  file { $properties_file:
    ensure  => 'present',
    owner   => $fstep::globals::user,
    group   => $fstep::globals::group,
    content => epp('fstep/zoomanager/application.properties.epp', {
      'logging_config_file' => $logging_config_file,
      'server_port'         => $real_application_port,
      'grpc_port'           => $real_grpc_port,
      'serviceregistry_url' => $real_serviceregistry_url,
      'zcfg_path'           => $zcfg_path,
      'javac_classpath'     => join($classpath_jar_files, ':'),
      'services_stub_jar'   => $services_stub_jar,
      'custom_properties'   => $custom_config_properties,
    }),
    require => Package['fs-tep-zoomanager'],
    notify  => Service['fs-tep-zoomanager'],
  }

  service { 'fs-tep-zoomanager':
    ensure     => $service_ensure,
    enable     => $service_enable,
    hasrestart => true,
    hasstatus  => true,
    require    => [Package['fs-tep-zoomanager'], File[$properties_file]],
  }

}
