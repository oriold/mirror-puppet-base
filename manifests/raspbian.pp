
# For raspbian hosts

class base::raspbian (

){

  package { "unattended-upgrades":
    ensure => installed,
  }

}
