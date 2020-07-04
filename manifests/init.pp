# Basic module
class base (

  $base_packages    = undef,
  $kbd_lang         = 'es',
  $local_packages   = undef,
  $ntp_master       = undef,
  $ntp_sensors      = true,
  $ntp_servers      = 'time.cloudflare.com',
  $openbsd_apmd     = '-A',
  $openbsd_mirror   = undef,
  $ssh_allow_groups = undef,
  $vault_addr       = undef,
  $vault_token      = undef,

){

  # Hiera
  $local_user  = hiera('desktop::local_user')
  $ssh_service = hiera('ssh_service')
  $ssl_dir     = hiera('ssl_dir')

  # Paquetes
  package { [ $base_packages, $local_packages ] :
    ensure => installed,
  }

  file { '/etc/ssh/sshd_config' :
    owner   => root,
    group   => 0,
    mode    => '0644',
    content => template('base/sshd_config.erb'),
    notify  => Service[$ssh_service],
  }

  file { '/usr/local/bin/unbound-block-hosts.pl' :
    owner   => root,
    group   => 0,
    mode    => '0755',
    content => template('base/unbound-block-hosts.pl.erb'),
  }

  # SSL
  file { "${ssl_dir}/dhparam.pem" :
    owner  => root,
    group  => 0,
    mode   => '0600',
    source => 'puppet:///modules/base/dhparam.pem',
  }

  file { "${ssl_dir}/dhparam-4096.pem" :
    owner  => root,
    group  => 0,
    mode   => '0600',
    source => 'puppet:///modules/base/dhparam-4096.pem',
  }

  # GeoIP
  file { '/usr/local/bin/update-geoip.sh' :
    owner  => root,
    group  => 0,
    mode   => '0755',
    source => 'puppet:///modules/base/update-geoip.sh',
  }

  cron { 'update-geoip' :
    ensure  => present,
    command => "/usr/local/bin/update-geoip.sh > /dev/null 2>&1",
    user    => root,
    minute  => fqdn_rand(60),
    hour    => 11,
    require => File['/usr/local/bin/update-geoip.sh'],
  }

  # motd
  file { '/etc/motd':
    owner  => root,
    group  => 0,
    mode   => '0644',
    source => 'puppet:///modules/base/motd',
  }
  
}

