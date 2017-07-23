class fstep::monitor(){

  require ::fstep::globals
  require ::epel

  contain ::fstep::monitor::grafana
  contain ::fstep::monitor::influxdb
  contain ::fstep::monitor::telegraf
  contain ::fstep::monitor::graylog_server

}

