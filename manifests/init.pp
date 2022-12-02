# Basic module
class base (

  $admin_group      = 'wheel',
  $base_packages    = undef,
  $bin_dir          = undef,
  $blacklistd       = undef,
  $etc_dir          = undef,
  $kbd_lang         = 'es',
  $local_packages   = undef,
  $ntp_master       = undef,
  $ntp_rdate        = undef,
  $ntp_sensors      = true,
  $ntp_servers      = 'time.cloudflare.com',
  $openbsd_apmd     = '-A',
  $openbsd_mirror   = undef,
  $snap_packages    = undef,
  $ssh_allow_groups = undef,
  $unbound_cron     = false,
  $unbound_path     = undef,
  $unbound_restart  = undef,
  $uninstall_pkgs   = undef,
  $vault_addr       = undef,
  $vault_token      = undef,

){

  # Hiera
  $local_user  = hiera('desktop::local_user')
  $ssh_service = hiera('ssh_service')
  $ssl_dir     = hiera('ssl_dir')

  if $facts['os']['family'] == 'Alpine' {
    Package { provider => 'apk' }
    Service { provider => 'openrc' }
  }

  # Packages uninstall
  package { $uninstall_pkgs :
    ensure => absent,
  }
  
  # SSH
  service { $ssh_service :
    ensure => running,
  }

  file { '/etc/ssh/sshd_config' :
    owner   => root,
    group   => 0,
    mode    => '0644',
    content => template('base/sshd_config.erb'),
    notify  => Service[$ssh_service],
  }

  file { '/usr/local/bin/unbound-block-hosts.pl' :
    ensure => absent,
  }

  file { '/usr/local/bin/unbound-block-hosts.sh' :
    owner   => root,
    group   => 0,
    mode    => '0755',
    content => template('base/unbound-block-hosts.sh.erb'),
  }

  if $unbound_cron {
    cron { 'update-unbound' :
      ensure  => present,
      command => "/usr/local/bin/unbound-block-hosts.sh && ${unbound_restart} > /dev/null 2>&1",
      user    => root,
      minute  => fqdn_rand(30),
      hour    => 10,
      require => File['/usr/local/bin/unbound-block-hosts.sh'],
    }
  }
  else {
    cron { 'update-unbound':
      ensure => absent,
    }
  }

  # Doas
  file { "${etc_dir}/doas.conf" :
    owner   => root,
    group   => 0,
    mode    => '0600',
    content => template('base/doas.conf.erb'),
  }

  # Backups
  group { 'backups' :
    ensure => present,
    gid    => 1003,
  }

  user { 'backups' :
    ensure     => present,
    uid        => 1003,
    managehome => true,
    require    => Group['backups'],
  }

  file { '/home/backups/.ssh' :
    ensure  => directory,
    owner   => backups,
    group   => backups,
    mode    => '0700',
    require => User['backups'],
  }
  -> file { '/home/backups/.ssh/authorized_keys' :
    owner  => backups,
    group  => backups,
    mode   => '0600',
    source => 'puppet:///modules/base/backups.pub',
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

