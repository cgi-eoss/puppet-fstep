class fstep::worker::privileges(
  $user  = undef,
  $admin = undef
){
$uid = pick($user, $fstep::globals::user)
$admin_uid = pick($admin, $fstep::globals::admin_user)
sudo::conf { "$uid":
  priority => 60,
  content  => "$uid ALL=(ALL) NOPASSWD:/usr/sbin/xfs_quota",
}

sudo::conf { "admin":
  priority => 10,
  content  => "$admin_uid ALL=(ALL) NOPASSWD:ALL",
}

}
