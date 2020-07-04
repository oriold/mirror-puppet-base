
# For Debian/Ubuntu
class base::debian (

) inherits base {

  # NTP
  class { '::ntp' :
    servers => [ $ntp_servers ],
  }

  # GeoIP
  file { '/var/db' :
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }
  ->
  file { '/var/db/geoip' :
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }

  # Vault
  file { '/etc/profile.d/local-vault.sh' :
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('base/local-vault.sh.erb'),
  }

  if $facts['os']['hardware'] == 'x86_64' {
    file { "/usr/local/bin/vault" :
      owner => root,
      group => root,
      mode  => '0755',
      source => 'puppet:///modules/base/Debian/vault',
    }
  }

  # SSH
  service { $ssh_service :
    ensure => running,
  }

}
