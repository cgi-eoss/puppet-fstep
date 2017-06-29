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

  class { 'kubernetes::node::kube_proxy':
    master => "http://${real_kubernetes_master_ip}:8080",
  }
}

