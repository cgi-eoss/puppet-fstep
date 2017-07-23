class fstep::kubernetes::master(
  $kubernetes_master_hostname = $::fqdn,
) {

  require ::fstep::globals
  require ::epel

  $real_kubernetes_master_hostname = pick($kubernetes_master_hostname, $fstep::globals::kubernetes_master_hostname)

  include ::kubernetes::client

  class { 'etcd':
    ensure                     => 'latest',
    listen_client_urls    => 'http://0.0.0.0:2379',
    advertise_client_urls => 'http://0.0.0.0:2379',
  }

  class { 'kubernetes::master::apiserver':
    ensure                   => running,
    allow_privileged         => true,
    service_cluster_ip_range => '10.1.0.0/16',
    etcd_servers             => [ "http://${real_kubernetes_master_hostname}:2379" ],
    insecure_bind_address    => "0.0.0.0"
  }

  class { 'kubernetes::master::scheduler':
    master => "${real_kubernetes_master_hostname}:8080",
  }

  etcd_key { '/foodsecurity/network/config': value => '{ "Network": "10.1.0.0/16" }' }

  class { 'flannel':
    # validate_bool($service_enable, $manage_docker, $journald_forward_enable, $kube_subnet_mgr)
    service_enable          => true,
    manage_docker           => false,
    journald_forward_enable => false,
    kube_subnet_mgr         => false,
    etcd_endpoints          => [ "http://${real_kubernetes_master_hostname}:2379" ],
    etcd_prefix             => '/foodsecurity/network',
  }
}
