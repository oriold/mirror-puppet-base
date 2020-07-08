# For Gentoo
class base::gentoo (

) inherits base {

  # Paquetes
  package { [ $base_packages, $local_packages ] :
    ensure => installed,
  }

  package { 'cronie' :
    ensure => installed,
  }

  service { 'cronie' :
    ensure  => running,
    enable  => true,
    require => Package['cronie'],
  }

  package { 'openntpd' :
    ensure => installed,
  }

  service { 'openntpd' :
    ensure  => running,
    enable  => true,
    require => Package['openntpd'],
  }

  file { '/etc/ntpd.conf' :
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('base/ntpd.conf.erb'),
    notify  => Service['openntpd'],
  }

  file { '/var/db/geoip' :
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }

  # Vault
  file { '/etc/profile.d/local-vault.sh' :
    owner   => root,
    group   => wheel,
    mode    => '0644',
    content => template('base/local-vault.sh.erb'),
  }

}
