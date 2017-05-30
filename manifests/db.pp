class fstep::db(
  $trust_local_network = false,
) {

  require ::fstep::globals

  contain ::fstep::db::postgresql

}