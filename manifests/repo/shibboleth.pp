class fstep::repo::shibboleth {

  $repo_descr = $::operatingsystemmajrelease ? {
    '6'     => 'Shibboleth (CentOS_CentOS-6)',
    '7'     => 'Shibboleth (CentOS_7)',
    default => fail("Unrecognised OS major release version ${::operatingsystemmajrelease}")
  }

  $repo_baseurl = $::operatingsystemmajrelease ? {
    '6'     => 'http://download.opensuse.org/repositories/security:/shibboleth/CentOS_CentOS-6/',
    '7'     => 'http://download.opensuse.org/repositories/security:/shibboleth/CentOS_7/',
    default => fail("Unrecognised OS major release version ${::operatingsystemmajrelease}")
  }

  $repo_gpgkey = "${repo_baseurl}repodata/repomd.xml.key"

  ensure_resource('yumrepo', 'shibboleth', {
    ensure   => 'present',
    descr    => $repo_descr,
    baseurl  => $repo_baseurl,
    enabled  => 1,
    gpgcheck => 1,
    gpgkey   => $repo_gpgkey,
  })
}
