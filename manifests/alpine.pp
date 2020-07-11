# For Alpine
class base::alpine (

) inherits base {

  Package { provider => 'apk' }
  Service { provider => 'openrc' }

  # Paquetes
  package { [ $base_packages, $local_packages ] :
    ensure => installed,
  }
  
}
