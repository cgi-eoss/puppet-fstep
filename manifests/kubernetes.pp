class ftep::kubernetes(){

  require ::ftep::globals
  require ::epel

  contain ::ftep::kubernetes::master
  contain ::ftep::kubernetes::worker

}

