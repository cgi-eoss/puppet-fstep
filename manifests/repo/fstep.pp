# FS-TEP package repository
class fstep::repo::fstep {
  ensure_resource(yumrepo, 'fstep', {
    ensure   => 'present',
    descr    => 'FS-TEP',
    baseurl  => $fstep::repo::location,
    enabled  => 1,
    gpgcheck => 0,
  })

  # Ensure this (and all other) yumrepos are available before packages
  Yumrepo <| |> -> Package <| provider != 'rpm' |>
}