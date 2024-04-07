# For Alpine
class base::alpine (

) inherits base {

  Package { provider => 'apk' }
  Service { provider => 'openrc' }

  # Paquetes
  package { [ $base_packages, $local_packages ] :
    ensure => installed,
  }

  # cron
  package { [ 'dcron', 'dcron-doc' ] :
    ensure => installed,
  }

  service { 'crond' :
    ensure => stopped,
    enable => false,
  }

  service { 'dcron' :
    ensure  => running,
    enable  => true,
    require => Package['dcron'],
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
  if $facts['os']['hardware'] == 'aarch64' {
    $vault_file = "vault_arm64"
  } else {
    $vault_file = "vault_amd64"
  }

  file { '/usr/local/bin/vault' :
    owner  => root,
    group  => 0,
    mode   => '0755',
    source => "puppet:///modules/base/${vault_file}",
  }
  
  file { '/etc/profile.d/local-vault.sh' :
    owner   => root,
    group   => wheel,
    mode    => '0644',
    content => template('base/local-vault.sh.erb'),
  }

  # maintenance
  if $maintenance {
    package { 'apk-cron' :
      ensure => installed,
    }
  }
}
