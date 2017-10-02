class fstep::common::docker (
) {

  require ::fstep::common::user
  require ::fstep::globals

  class { '::docker':
    docker_users => [$fstep::globals::user],
  }

}

