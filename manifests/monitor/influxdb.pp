class fstep::monitor::influxdb(
  $db_name = 'fstep',
  $db_username = 'fstep_user',
  $db_password = 'fstep_pass',
  $monitor_data_port = '8086'
) {

  require ::fstep::globals
  require ::epel

  $real_monitor_data_port = pick($monitor_data_port, $fstep::globals::monitor_data_port)

  class {'influxdb::server':
    http_bind_address => ":$real_monitor_data_port",
  }
}
