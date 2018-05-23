class fstep::drupal (
  $drupal_site      = 'foodsecurity-tep.eo.esa.int',
  $drupal_version   = '7.59',
  $www_path         = '/var/www/html/drupal',
  $www_user         = 'apache',

  $db_host          = undef,
  $db_name          = undef,
  $db_user          = undef,
  $db_pass          = undef,
  $db_port          = '5432',
  $db_driver        = 'pgsql',
  $db_prefix        = 'drupal_',

  $init_db          = true,
  $enable_cron      = true,
) {

  require ::fstep::globals
  require ::epel

  contain ::fstep::common::php

  class { '::postgresql::client': }

  $real_db_host = pick($db_host, $::fstep::globals::db_hostname)
  $real_db_name = pick($db_name, $::fstep::globals::fstep_db_name)
  $real_db_user = pick($db_user, $::fstep::globals::fstep_db_username)
  $real_db_pass = pick($db_pass, $::fstep::globals::fstep_db_password)

  file { $www_path:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
  }

  class { ::drupal:
    www_dir     => $www_path,
    www_process => $www_user,
    require     => Class['::php'],
  }

  ::drupal::site { $drupal_site:
    core_version     => $drupal_version,
    modules          => {
      'advanced_forum'    => '2.6',
      'backup_migrate'    => '3.1',
      'ctools'            => '1.12',
      'registry_autoload' => '1.3',
      'shib_auth'         => '4.4',
      'twitter_block'     => '2.3',
      'views'             => '3.16',
    },
    settings_content => epp('fstep/drupal/settings.php.epp', {
      'db'         => {
        'host'     => $real_db_host,
        'database' => $real_db_name,
        'username' => $real_db_user,
        'password' => $real_db_pass,
        'port'     => $db_port,
        'driver'   => $db_driver,
        'prefix'   => $db_prefix,
      },
      'fstep_proxy' => $::fstep::globals::proxy_hostname,
    }),
    cron_file_ensure => $enable_cron ? {
      true    => 'present',
      default => 'absent'
    },
    require          => [Class['::drupal']],
  }

  $site_path = "${www_path}/${drupal_site}"

  class { ::fstep::drupal::apache:
    site_path => $site_path
  }

  # Install the site if the database is not yet initialised
  if $init_db {
    $drush_site_install = "${::drupal::drush_path} -y site-install"
    $drush_si_options = "standard install_configure_form.update_status_module='array(FALSE,FALSE)'"

    $drupal_site_install_requires = defined(Class["::fstep::db"]) ? {
      true    => [Class['::fstep::db'], Drupal::Site[$drupal_site]],
      default => [Drupal::Site[$drupal_site]]
    }

    exec { 'drupal-site-install':
      command => "${drush_site_install} ${drush_si_options} --root=${site_path} 2>&1",
      unless  => [
        "/usr/bin/test -n \"`${::drupal::drush_path} status bootstrap --field-labels=0 --root=${site_path} 2>&1`\""
      ],
      require => $drupal_site_install_requires,
    }
  }

}
