class ftep::kubernetes::master(
  $kubernetes_master_ip = '192.168.101.13',
) {

  require ::ftep::globals
  require ::epel

  $real_kubernetes_master_ip = pick($kubernetes_master_ip, $ftep::globals::kubernetes_master_ip)

  include ::kubernetes::client

  class { 'etcd':
    listen_client_urls          => 'http://0.0.0.0:2379',
    advertise_client_urls       => "http://${real_kubernetes_master_ip}:2379,http://127.0.0.1:2379",
    listen_peer_urls            => 'http://0.0.0.0:2380',
    initial_advertise_peer_urls => "http://${real_kubernetes_master_ip}:2380,http://127.0.0.1:2379",
    initial_cluster             => [
      "${::hostname}=http://${::fqdn}:2380",
      ],
  } ->

  class { 'kubernetes::master::apiserver':
    ensure => running,
    allow_privileged => true,
    service_cluster_ip_range => '192.168.5.0/24'
  } ->
  class { 'kubernetes::master::scheduler':
    master => "${real_kubernetes_master_ip}:8080",
  }
}

