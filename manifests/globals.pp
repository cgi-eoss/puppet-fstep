# Class for setting cross-class global overrides.
class fstep::globals (
  $manage_package_repo              = true,

  # Base URL for fstep::proxy
  $base_url                         = "http://${facts['fqdn']}",
  $drupal_url                       = 'https://foodsecurity-tep.net',

  # Context paths for reverse proxy
  $context_path_geoserver           = '/geoserver',
  $context_path_geoserver_contrib   = '/geoserver-contrib',
  $context_path_resto               = '/resto',
  $context_path_webapp              = '/app',
  $context_path_wps                 = '/secure/wps',
  $context_path_api_v2              = '/secure/api/v2.0',
  $context_path_monitor             = '/monitor',
  $context_path_logs                = '/logs',
  $context_path_eureka              = '/eureka',
  $context_path_analyst             = '/analyst',
  $context_path_broker             = '/broker',
  
  # System user
  $user                             = 'fstep',
  $group                            = 'fstep',
  $admin_user                       = 'eouser',
  # Hostnames and IPs for components
  $db_hostname                      = 'fstep-db',
  $db_ip                            = '192.168.0.1',
  $drupal_hostname                  = 'fstep-drupal',
  $drupal_ip                        = '192.168.0.2',
  $geoserver_hostname               = 'fstep-geoserver',
  $geoserver_ip                     = '192.168.0.3',
  $proxy_hostname                   = 'fstep-proxy',
  $proxy_ip                         = '192.168.0.4',
  $webapp_hostname                  = 'fstep-webapp',
  $webapp_ip                        = '192.168.0.5',
  $wps_hostname                     = 'fstep-wps',
  $wps_ip                           = '192.168.0.6',
  $server_hostname                  = 'fstep-server',
  $server_ip                        = '192.168.0.7',
  $monitor_hostname                 = 'fstep-monitor',
  $monitor_ip                       = '192.168.0.8',
  $resto_hostname                   = 'fstep-resto',
  $resto_ip                         = '192.168.0.9',
  $broker_hostname                  = 'fstep-broker',
  $broker_ip                        = '192.168.0.10',
  $default_gui_hostname             = 'fstep-worker',
  $default_gui_ip                   = '192.168.0.11',
  $ui_hostname                      = 'fstep-ui',
  $ui_ip                            = '192.168.0.12',
  $geoserver_contrib_hostname       = 'fstep-geoserver-contrib',
  $geoserver_contrib_ip             = '192.168.0.13',
  $kubernetes_master_hostname       = 'fskubermaster',

  $hosts_override                   = { },

  # All classes should share this database config, or override it if necessary
  $fstep_db_name                     = 'fstep',
  $fstep_db_v2_name                  = 'fstep_v2',
  $fstep_db_username                 = 'fstepuser',
  $fstep_db_password                 = 'fsteppass',
  $fstep_db_resto_name               = 'fstep_resto',
  $fstep_db_resto_username           = 'fstepresto',
  $fstep_db_resto_password           = 'fsteprestopass',
  $fstep_db_resto_su_username        = 'fsteprestoadmin',
  $fstep_db_resto_su_password        = 'fsteprestoadminpass',
  $fstep_db_geoserver_name               = 'fstep_geoserver',
  $fstep_db_geoserver_username           = 'fstepgeoserver',
  $fstep_db_geoserver_password           = 'fstepgeoserverpass',
  $fstep_db_zoo_name                 = 'fstep_zoo',
  $fstep_db_zoo_username             = 'fstepzoo',
  $fstep_db_zoo_password             = 'fstepzoopass',

  # SSO configuration
  $username_request_header          = 'REMOTE_USER',
  $email_request_header             = 'REMOTE_EMAIL',

  # Eureka config
  $serviceregistry_user             = 'fstepeureka',
  $serviceregistry_pass             = 'fstepeurekapass',

  # App server config for HTTP and gRPC
  $serviceregistry_application_port = 8761,
  $server_application_port          = 8090,
  $worker_application_port          = 8091,
  $zoomanager_application_port      = 8092,
  $server_grpc_port                 = 6565,
  $worker_grpc_port                 = 6566,
  $zoomanager_grpc_port             = 6567,

  # Geoserver config
  $geoserver_port                   = 9080,
  $geoserver_stopport               = 9079,
  $geoserver_fstep_username          = 'fstepgeoserver',
  $geoserver_fstep_password          = 'fstepgeoserverpass',

  $geoserver_contrib_port           = 9080,
    
  # Resto config
  $resto_fstep_username              = 'fstepresto',
  $resto_fstep_password              = 'fsteprestopass',

  # Broker config
  $broker_fstep_username              = 'fstepbroker',
  $broker_fstep_password              = 'fstepbrokerpass',

  # monitor config
  $grafana_port                     = 8089,
  $monitor_data_port                = 8086,

  # graylog config
  $graylog_secret                   = 'bQ999ugSIvHXfWQqrwvAomNxaMsErX6I4UWicpS9ZU8EDmuFnhX9AmcoM43s4VGKixd2f6d6cELbRuPWO5uayHnBrBbNWVth',
  # sha256 of graylogpass:
  $graylog_sha256                   = 'a7fdfe53e2a13cb602def10146388c65051c67e60ee55c051668a1c709449111',
  $graylog_port                     = 8087,
  $graylog_context_path             = '/logs',
  $graylog_api_path                 = '/logs/api',
  $graylog_gelf_tcp_port            = 12201,
  $graylog_api_fstep_username        = 'fstepgraylog',
  $graylog_api_fstep_password        = 'fstepgraylogpass',

  $enable_log4j2_graylog            = false,
  
  # API Proxy config
  $fstep_db_v2_api_keys_table= 'keytable',
  $fstep_db_v2_api_users_table= 'usertable',
  $fstep_db_v2_api_keys_reader_username= 'username',
  $fstep_db_v2_api_keys_reader_password= 'password',
  $proxy_dbd_db= 'fstepdb',
  $proxy_dbd_port= 10000,
  $proxy_dbd_dbdriver= 'dbdriver',
  $proxy_dbd_query= 'dbquery', 
) {

  # Alias reverse-proxy hosts via hosts file
  ensure_resources(host, $hosts_override)

  # Setup of the repo only makes sense globally, so we are doing this here.
  if($manage_package_repo) {
    require ::fstep::repo
  }
}
