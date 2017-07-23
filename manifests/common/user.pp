class fstep::common::user (
  $user  = undef,
  $group = undef,
  $home  = '/home/fstep'
) {

  $uid = pick($user, $fstep::globals::user)
  $gid = pick($group, $fstep::globals::group)

  group { $gid:
    ensure => present,
  }

  user { $uid:
    ensure     => present,
    gid        => $gid,
    managehome => true,
    home       => $home,
    shell      => '/bin/bash',
    system     => true,
    require    => Group[$gid],
  }

}