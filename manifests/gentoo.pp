# For Gentoo
class base::gentoo (
  $accept_license = undef,
  $common_flags   = undef,
  $makeopts       = undef,
  $mirrors        = undef,
  $use            = undef,
  $video_cards    = undef,

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

  file { '/etc/conf.d/keymaps' :
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('base/Gentoo/keymaps.erb'),
  }

  file { '/etc/env.d/02locale' :
    owner  => root,
    group  => root,
    mode   => '0644',
    source => 'puppet:///modules/base/Gentoo/02locale',
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

  package { 'app-admin/sysklogd' :
    ensure => installed,
  }

  service { 'sysklogd' :
    ensure  => running,
    enable  => true,
    require => Package['app-admin/sysklogd'],
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
