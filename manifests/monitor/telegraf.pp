class fstep::monitor::telegraf(
  $influx_host = 'fstep-monitor',
  $influx_port = '8086',
  $influx_db   = 'fstep',
  $influx_user = 'fstep_user',
  $influx_pass = 'fstep_pass'
) {

  require ::fstep::globals
  require ::epel

  $real_influx_host = pick($influx_host, $fstep::globals::monitor_hostname)
  $real_influx_port = pick($influx_port, $fstep::globals::monitor_data_port)

  class { '::telegraf':
    hostname => $::hostname,
    outputs  => {
        'influxdb' => {
            'urls'     => [ "http://${real_influx_host}:${real_influx_port}" ],
            'database' => $influx_db,
            'username' => $influx_user,
            'password' => $influx_pass,
            }
        },
    inputs   => {
        'cpu' => {
            'percpu'   => true,
            'totalcpu' => true,
        },
    }
  }
}
