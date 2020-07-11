# For Alpine
class base::alpine (

) inherits base {

  Package { provider => 'apk' }
  Service { provider => 'openrc' }

  # Paquetes
  package { [ $base_packages, $local_packages ] :
    ensure => installed,
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

  file { '/etc/conf.d/loadkmap' :
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('base/Alpine/loadkmap.erb'),
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
