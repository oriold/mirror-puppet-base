
# For FreeBSD
class base::freebsd (

) inherits base {

  # Paquetes
  package { [ $base_packages, $local_packages ] :
    ensure => installed,
  }

  # NTP
  class { '::ntp' :
    servers => [ $ntp_servers ],
  }

  file { '/usr/local/etc/sudoers' :
    owner   => root,
    group   => wheel,
    mode    => '0440',
    source  => 'puppet:///modules/base/FreeBSD/sudoers',
    require => Package['sudo'],
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

  # SSH
  service { $ssh_service :
    ensure => running,
  }

}
