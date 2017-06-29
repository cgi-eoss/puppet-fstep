class ftep::kubernetes(){

  require ::ftep::globals
  require ::epel
  require ::etcd
  require ::kubernetes::master
  require ::kubernetes::node

  contain ::ftep::kubernetes::master
  contain ::ftep::kubernetes::worker

}

