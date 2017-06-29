class ftep::kubernetes::master(
  $kubernetes_master_ip = '192.168.101.13',
) {

  require ::ftep::globals
  require ::epel

  $real_kubernetes_master_ip = pick($kubernetes_master_ip, $ftep::globals::kubernetes_master_ip)

  include ::kubernetes::client

  class { 'etcd':
    ensure                     => 'latest',
    listen_client_urls    => 'http://0.0.0.0:2379',
    advertise_client_urls => 'http://0.0.0.0:2379',
  }

  class { 'kubernetes::master::apiserver':
    ensure                   => running,
    allow_privileged         => true,
    service_cluster_ip_range => '192.168.5.0/24',
    etcd_servers             => [ "http://${real_kubernetes_master_ip}:2379" ],
    insecure_bind_address    => "${real_kubernetes_master_ip}"
  }

  class { 'kubernetes::master::scheduler':
    master => "${real_kubernetes_master_ip}:8080",
  }

  class { 'kubernetes::node::kube_proxy':
    master => "http://${real_kubernetes_master_ip}:8080",
  }

  class { 'flannel':
    etcd_endpoints => "http://${real_kubernetes_master_ip}:2379",
    etcd_prefix    => '/coreos.com/network',
  }
}
