# For Gentoo
class base::gentoo (
  $accept_license = '-* @FREE',
  $common_flags   = '-march=native -O2 -pipe',
  $makeopts       = '-j2',
  $mirrors        = 'https://mirror.bytemark.co.uk/gentoo/',

) inherits base {

  # Paquetes
  file { '/etc/portage/make.conf' :
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('base/Gentoo/make.conf.erb'),
  }

  file { '/etc/portage/package.license' :
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }
  ->
  file { '/etc/portage/package.license/kernel' :
    owner => root,
    group => root,
    mode  => '0644',
    source => 'puppet:///modules/base/Gentoo/license.kernel',
  }
  
  package { $local_packages :
    ensure => installed,
  }

  package { 'sys-process/cronie' :
    ensure => installed,
  }

  service { 'cronie' :
    ensure  => running,
    enable  => true,
    require => Package['sys-process/cronie'],
  }

  package { 'net-misc/openntpd' :
    ensure => installed,
  }

  service { 'ntpd' :
    ensure  => running,
    enable  => true,
    require => Package['net-misc/openntpd'],
  }

  file { '/etc/ntpd.conf' :
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('base/ntpd.conf.erb'),
    notify  => Service['ntpd'],
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
