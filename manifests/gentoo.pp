# For Gentoo
class base::gentoo (

) inherits base {

  package { 'cronie' :
    ensure => installed,
  }

  service { 'cronie' :
    ensure  => running,
    enable  => true,
    require => Package['cronie'],
  }

}
