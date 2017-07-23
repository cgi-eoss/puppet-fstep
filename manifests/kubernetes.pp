class fstep::kubernetes(){

  require ::fstep::globals
  require ::epel

  require ::etcd
  require ::kubernetes::master
  require ::kubernetes::node

  contain ::fstep::kubernetes::master
  contain ::fstep::kubernetes::worker

}

