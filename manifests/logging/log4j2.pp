define fstep::logging::log4j2 (
  String $fstep_component,
  String $log_level               = 'info',
  String $config_file             = $name,
  Boolean $is_spring_context      = true,
  Boolean $enable_graylog         = $fstep::globals::enable_log4j2_graylog,
  String $graylog_server          = $fstep::globals::monitor_hostname,
  String $graylog_protocol        = 'TCP',
  Integer $graylog_port           = $fstep::globals::graylog_gelf_tcp_port,
  String $graylog_source_hostname = $trusted['certname'],
) {
  file { $config_file:
    ensure  => 'present',
    owner   => 'fstep',
    group   => 'fstep',
    content => epp('fstep/logging/log4j2.xml.epp', {
      'fstep_component'          => $fstep_component,
      'log_level'               => $log_level,
      'is_spring_context'       => $is_spring_context,
      'enable_graylog'          => $enable_graylog,
      'graylog_server'          => $graylog_server,
      'graylog_protocol'        => $graylog_protocol,
      'graylog_port'            => $graylog_port,
      'graylog_source_hostname' => $graylog_source_hostname
    })
  }
}