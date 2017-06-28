class ftep::kubernetes::worker(
  $kubernetes_master_ip = 'localhost',
) {

  require ::ftep::globals
  require ::epel

  $real_kubernetes_master_ip = pick($kubernetes_master_ip, $ftep::globals::kubernetes_master_ip)

}

