# Install and manage GeoServer for WMS/WFS
class fstep::geoserver (
  $group                  = 'geoserver',
  $user                   = 'geoserver',
  $user_home              = '/home/geoserver',
  $geoserver_home         = '/opt/geoserver',
  $geoserver_data_dir     = '/opt/geoserver-data',
  $config_file            = '/etc/default/geoserver',
  $init_script            = '/etc/init.d/geoserver',
  $systemd_unit           = '/usr/lib/systemd/system/geoserver.service',

  $geoserver_version      = '2.12.1',
  $geoserver_download_url = 'http://sourceforge.net/projects/geoserver/files/GeoServer/2.12.1/geoserver-2.12.1-bin.zip',
  $geoserver_extension    = 'zip',
  $geoserver_digest       = '704c1eb7b9e2a904f76954acfd1c756568094694',
  $geoserver_digest_type  = 'sha1',
  $geoserver_port         = undef,
  $geoserver_stopport     = undef,

  $ncwms_plugin           = 'geoserver-2.12-SNAPSHOT-ncwms-plugin',
  $wmts_plugin            = 'geoserver-2.12-SNAPSHOT-wmts-multi-dimensional-plugin',
  $csw_plugin             = 'geoserver-2.12.1-csw-plugin',
  $wcs_eo_plugin          = 'geoserver-2.12.1-wcs2_0-eo-plugin',
  $wps_plugin             = 'geoserver-2.12.1-wps-plugin',

  $ncwms_download_url     = 'http://ares.boundlessgeo.com/geoserver/2.12.x/community-latest/geoserver-2.12-SNAPSHOT-ncwms-plugin.zip',
  $wmts_download_url      = 'http://ares.boundlessgeo.com/geoserver/2.12.x/community-latest/geoserver-2.12-SNAPSHOT-wmts-multi-dimensional-plugin.zip',
  $csw_download_url       = 'http://sourceforge.net/projects/geoserver/files/GeoServer/2.12.1/extensions/geoserver-2.12.1-csw-plugin.zip',
  $wcs_eo_download_url    = 'http://sourceforge.net/projects/geoserver/files/GeoServer/2.12.1/extensions/geoserver-2.12.1-wcs2_0-eo-plugin.zip',
  $wps_download_url       = 'http://sourceforge.net/projects/geoserver/files/GeoServer/2.12.1/extensions/geoserver-2.12.1-wps-plugin.zip'
) {

  require ::fstep::globals

  contain ::fstep::common::java

  group { $group:
    ensure => present,
  }

  user { $user:
    ensure     => present,
    gid        => $group,
    managehome => true,
    home       => $user_home,
    shell      => '/bin/bash',
    system     => true,
    require    => Group[$group],
  }

  ensure_packages(['unzip'])

  # This is created by the ::archive resource
  $geoserver_path = "${user_home}/geoserver-2.12.1"

  # Download and unpack the standalone platform-independent binary distribution
  $archive = "geoserver-${geoserver_version}"
  archive { $archive:
    path          => "${user_home}/${archive}.zip",
    source        => $geoserver_download_url,
    checksum      => $geoserver_digest,
    checksum_type => $geoserver_digest_type,
    user          => $user,
    extract       => true,
    extract_path  => $user_home,
    require       => [User[$user], Package['unzip']],
  }

  file { $geoserver_home:
    ensure  => link,
    target  => $geoserver_path,
    require => Archive[$archive],
  }
  file { $geoserver_data_dir:
    ensure  => directory,
    mode    => '0755',
    owner   => $user,
    require => User[$user],
  }

  $config_file_epp = @(END)
JAVA_HOME="<%= $java_home %>"
GEOSERVER_USER="<%= $geoserver_user %>"
GEOSERVER_HOME="<%= $geoserver_home %>"
GEOSERVER_DATA_DIR="<%= $geoserver_data_dir %>"
PORT="<%= $port %>"
STOPPORT="<%= $stopport %>"
END

  $real_port = pick($geoserver_port, $fstep::globals::geoserver_port)
  $real_stopport = pick($geoserver_stopport, $fstep::globals::geoserver_stopport)

  file { $config_file:
    ensure  => present,
    content => inline_epp($config_file_epp, {
      'java_home'          => '/etc/alternatives/jre',
      'geoserver_user'     => $user,
      'geoserver_home'     => $geoserver_home,
      'geoserver_data_dir' => $geoserver_data_dir,
      'port'               => "${real_port}",
      'stopport'           => "${real_stopport}",
    })
  }

  file { $init_script:
    ensure  => present,
    mode    => '0755',
    content => epp('fstep/geoserver/initscript.sh.epp'), # no parameterisation yet
    require => [User[$user], Archive[$archive], File[$config_file]],
  }

  file { $systemd_unit:
    ensure  => present,
    mode    => '0644',
    content => epp('fstep/geoserver/geoserver.service.epp', {
      'init_script' => $init_script,
    }),
    require => [User[$user], Archive[$archive], File[$init_script]],
  }

  # ncWMS plugin - http://ares.boundlessgeo.com/geoserver/2.12.x/community-latest/geoserver-2.12-SNAPSHOT-ncwms-plugin.zip
  # wmts plugin - http://ares.boundlessgeo.com/geoserver/2.12.x/community-latest/geoserver-2.12-SNAPSHOT-wmts-multi-dimensional-plugin.zip
  # csw plugin - http://sourceforge.net/projects/geoserver/files/GeoServer/2.12.1/extensions/geoserver-2.12.1-csw-plugin.zip
  # WCS 2.0 EO plugin http://sourceforge.net/projects/geoserver/files/GeoServer/2.12.1/extensions/geoserver-2.12.1-wcs2_0-eo-plugin.zip
  # wps plugin - http://sourceforge.net/projects/geoserver/files/GeoServer/2.12.1/extensions/geoserver-2.12.1-wps-plugin.zip
  $plugins_dir = "${geoserver_path}/webapps/geoserver/WEB-INF/lib"
  archive { $ncwms_plugin:
    path          => "${user_home}/${ncwms_plugin}.zip",
    source        => $ncwms_download_url,
    user          => $user,
    extract       => true,
    extract_path  => $plugins_dir,
    require       => [User[$user], Package['unzip']],
  }

  archive { $wmts_plugin:
    path          => "${user_home}/${wmts_plugin}.zip",
    source        => $wmts_download_url,
    user          => $user,
    extract       => true,
    extract_path  => $plugins_dir,
    require       => [User[$user], Package['unzip']],
  }

  archive { $csw_plugin:
    path          => "${user_home}/${csw_plugin}.zip",
    source        => $csw_download_url,
    user          => $user,
    extract       => true,
    extract_path  => $plugins_dir,
    require       => [User[$user], Package['unzip']],
  }

  archive { $wcs_eo_plugin:
    path          => "${user_home}/${wcs_eo_plugin}.zip",
    source        => $wcs_eo_download_url,
    user          => $user,
    extract       => true,
    extract_path  => $plugins_dir,
    require       => [User[$user], Package['unzip']],
  }
  
  archive { $wps_plugin:
    path          => "${user_home}/${wps_plugin}.zip",
    source        => $wps_download_url,
    user          => $user,
    extract       => true,
    extract_path  => $plugins_dir,
    require       => [User[$user], Package['unzip']],
  }

  service { 'geoserver':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => [File[$systemd_unit]],
  }

}
