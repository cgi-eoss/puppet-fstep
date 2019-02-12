class fstep::worker::privileges(
  $user  = undef
){
$uid = pick($user, $fstep::globals::user)

sudo::conf { "$uid":
  priority => 60,
  content  => "$uid ALL=(ALL) NOPASSWD:/usr/sbin/xfs_quota",
}

}
