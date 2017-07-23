class fstep::monitor::graylog_collector (
  $enable_syslog_collector = true,
  $enable_apache_collector = false,
  $graylog_api_url         = undef,
  $graylog_server          = undef,
  $graylog_gelf_tcp_port   = undef,
) {

  require ::fstep::globals

  $config_file = '/etc/graylog/collector/collector.conf'

  $real_graylog_api_url = pick($graylog_api_url, "${fstep::globals::base_url}${fstep::globals::graylog_api_path}")
  $real_graylog_server = pick($graylog_server, $fstep::globals::monitor_hostname)
  $real_graylog_gelf_tcp_port = pick($graylog_gelf_tcp_port, $fstep::globals::graylog_gelf_tcp_port)

  ensure_packages(['graylog-collector'], {
    ensure => 'present',
  })

  file { $config_file:
    ensure  => present,
    mode    => '640',
    content => epp('fstep/graylog-collector/collector.conf.epp', {
      'enable_syslog_collector' => $enable_syslog_collector,
      'enable_apache_collector' => $enable_apache_collector,
      'graylog_api_url'         => $real_graylog_api_url,
      'graylog_server'          => $real_graylog_server,
      'graylog_gelf_tcp_port'   => $real_graylog_gelf_tcp_port,
    }),
    require => Package['graylog-collector'],
    notify  => Service['graylog-collector'],
  }

  service { 'graylog-collector':
    ensure => 'running',
    enable => true,
    hasrestart => true,
    hasstatus  => true,
    require => [Package['graylog-collector'], File[$config_file]],
  }

}
