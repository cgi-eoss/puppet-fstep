class fstep::repo::webtatic {

  $repo_descr = $::operatingsystemmajrelease ? {
    '6'     => 'Webtatic Repository EL6 - $basearch',
    '7'     => 'Webtatic Repository EL7 - $basearch',
    default => fail("Unrecognised OS major release version ${::operatingsystemmajrelease}")
  }

  $repo_mirrorlist = $::operatingsystemmajrelease ? {
    '6'     => 'https://mirror.webtatic.com/yum/el6/$basearch/mirrorlist',
    '7'     => 'https://mirror.webtatic.com/yum/el7/$basearch/mirrorlist',
    default => fail("Unrecognised OS major release version ${::operatingsystemmajrelease}")
  }

  $repo_gpgkey = $::operatingsystemmajrelease ? {
    '6'     => 'https://mirror.webtatic.com/yum/RPM-GPG-KEY-webtatic-andy',
    '7'     => 'https://mirror.webtatic.com/yum/RPM-GPG-KEY-webtatic-el7',
    default => fail("Unrecognised OS major release version ${::operatingsystemmajrelease}")
  }

  ensure_resource(yumrepo, 'webtatic', {
    ensure     => 'present',
    descr      => $repo_descr,
    mirrorlist => $repo_mirrorlist,
    enabled    => 1,
    gpgcheck   => 1,
    gpgkey     => $repo_gpgkey,
  })

}
