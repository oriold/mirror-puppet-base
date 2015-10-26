
# Este es el módulo base con mi usuario, paquetes que quiera instalar, etc.

class base (

  $base_packages    = undef,
  $openbsd_packages = undef,
  $freebsd_packages = undef,
  $debian_packages  = undef,
  $ssh_allow_groups = undef,

  ) {

  # Hiera
  $ssh_service = hiera('ssh_service')

  # Paquetes
  package { $base_packages :
    ensure => installed,
  }

  if $::operatingsystem == 'OpenBSD' {
    package { $openbsd_packages :
      ensure => installed,
    }
  }

  if $::operatingsystem == 'FreeBSD' {
    package { $freebsd_packages :
      ensure => installed,
    }
  }

  if $::operatingsystem == 'Debian' {
    package { $debian_packages :
      ensure => installed,
    }
  }

  # SSH
  service { $ssh_service :
    ensure => running,
  }

  file { '/etc/ssh/sshd_config' :
    owner   => root,
    group   => 0,
    mode    => '0644',
    content => template('base/sshd_config.erb'),
    notify  => Service[$ssh_service],
  }
  
  
}
  
