
# For FreeBSD
class base::freebsd (

) inherits base {

  # Paquetes
  package { [ $base_packages, $local_packages ] :
    ensure => installed,
  }

  # NTP
  package { 'openntpd' :
    ensure => installed,
  }

  service { 'openntpd' :
    ensure => running,
  }

  file { '/usr/local/etc/ntpd.conf' :
    owner   => root,
    group   => wheel,
    mode    => '0644',
    content => template('base/ntpd.conf.erb'),
    notify  => Service['openntpd'],
    require => Package['openntpd'],
  }
  
  file { '/etc/make.conf' :
    owner  => root,
    group  => wheel,
    mode   => '0644',
    source => 'puppet:///modules/base/FreeBSD/make.conf',
  }

  # Profile directory
  file { '/etc/profile' :
    owner  => root,
    group  => wheel,
    mode   => '0644',
    source => 'puppet:///modules/base/FreeBSD/profile',
  }

  file { '/usr/local/etc/profile.d' :
    ensure => directory,
    owner  => root,
    group  => wheel,
    mode   => '0755',
  }

  file { '/var/db/geoip' :
    ensure => directory,
    owner  => root,
    group  => wheel,
    mode   => '0755',
  }

  # Vault
  file { '/usr/local/etc/profile.d/local-vault.sh' :
    owner   => root,
    group   => wheel,
    mode    => '0644',
    content => template('base/local-vault.sh.erb'),
    require => File['/usr/local/etc/profile.d'],
  }

}
