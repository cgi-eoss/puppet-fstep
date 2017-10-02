class fstep::broker (){

  require ::fstep::globals
  require ::epel

  class { 'activemq':
    version             => '5.14.5',
    install_dependencies => false,
    install_destination => '/opt',      # Default value
    create_user         => true,        # Default value
    process_user        => 'activemq',  # Default value
  }

}
