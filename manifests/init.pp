
# Este es el módulo base con mi usuario, paquetes que quiera instalar, etc.

class base (

  $base_packages    = undef,
  $openbsd_packages = undef,
  $freebsd_packages = undef,
  $debian_packages  = undef,

  ) {

  # Paquetes
  package { $base_packages :
    ensure => present,
  }

  if $::operatingsystem == 'OpenBSD' {
    package { $openbsd_packages :
      ensure => present,
    }
  }

  if $::operatingsystem == 'FreeBSD' {
    package { $freebsd_packages :
      ensure => present,
    }
  }

  if $::operatingsystem == 'Debian' {
    package { $debian_packages :
      ensure => present,
    }
  }
  
}
  
