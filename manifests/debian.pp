
# For Debian/Ubuntu
class base::debian (

) inherits base {

  # Paquetes
  package { [ $base_packages, $local_packages ] :
    ensure => installed,
  }

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

  -> file { '/var/db/geoip' :
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

  if $maintenance {
    package { 'cron-apt' :
      ensure => installed,
    }
  }
}
