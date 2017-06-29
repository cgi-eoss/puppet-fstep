class ftep::kubernetes::worker(
  $kubernetes_master_ip = '192.168.101.13',
) {

  require ::ftep::globals
  require ::epel

  $real_kubernetes_master_ip = pick($kubernetes_master_ip, $ftep::globals::kubernetes_master_ip)

  include ::kubernetes::client

  class { 'kubernetes::node::kubelet':
    ensure         => 'running',
    address        => '0.0.0.0',
    api_servers    => "http://${real_kubernetes_master_ip}:8080",
    register_node  => true,
    pod_cidr       => '10.1.0.0/16',
  }

  class { 'flannel':
    service_enable          => true,
    manage_docker           => false,
    journald_forward_enable => false,
    kube_subnet_mgr         => false,
    etcd_endpoints          => [ "http://${real_kubernetes_master_ip}:2379" ],
    etcd_prefix             => '/foodsecurity/network',
  }

  class { 'kubernetes::node::kube_proxy':
    master => "http://${real_kubernetes_master_ip}:8080",
  }
}
