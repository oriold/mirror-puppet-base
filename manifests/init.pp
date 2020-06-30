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
  
  case $facts['os']['family'] {

    'OpenBSD' : {

      $unbound_path = '/var/unbound/etc'

      service { 'apmd' :
        ensure => running,
        enable => true,
      }

      service { 'ntpd' :
        ensure => running,
        enable => true,
      }

      exec { 'apmd_flags' :
        command => "rcctl set apmd flags '${openbsd_apmd}'",
        path    => '/usr/local/bin:/usr/bin:/bin:/sbin:/usr/sbin',
        notify  => Service['apmd'],
      }

      # OpenNTPd server
      file { '/etc/ntpd.conf' :
        owner   => root,
        group   => wheel,
        mode    => '0644',
        content => template('base/ntpd.conf.erb'),
        notify  => Service['ntpd'],
      }

      file { '/etc/installurl' :
        owner   => root,
        group   => wheel,
        mode    => '0644',
        content => "${openbsd_mirror}\n",
      }

      file { '/etc/doas.conf' :
        owner  => root,
        group  => wheel,
        mode   => '0644',
        source => 'puppet:///modules/base/OpenBSD/doas.conf',
      }

      file { '/etc/iked/pubkeys/fqdn/gtw-3.the-grid.xyz' :
        owner  => root,
        group  => wheel,
        mode   => '0644',
        source => 'puppet:///modules/base/OpenBSD/gtw-3.the-grid.xyz',
      }

      file { '/etc/sysclean.ignore' :
        owner  => root,
        group  => wheel,
        mode   => '0644',
        source => 'puppet:///modules/base/OpenBSD/sysclean.ignore',
      }

      # Ports configuration
      file { '/etc/mk.conf' :
        owner  => root,
        group  => wheel,
        mode   => '0644',
        source => 'puppet:///modules/base/OpenBSD/mk.conf',
      }

      # KSH configuration
      file { [ '/etc/skel/.kshrc',
               '/root/.kshrc' ] :
        ensure => absent,
      }
      
      file { [ '/etc/skel/.profile',
               '/root/.profile' ] :
        owner  => root,
        group  => wheel,
        mode   => '0644',
        source => 'puppet:///modules/base/OpenBSD/skel.kshrc',
      }

      file { '/etc/wsconsctl.conf' :
        owner   => root,
        group   => wheel,
        mode    => '0644',
        content => template('base/OpenBSD/wsconsctl.conf.erb'),
      }

      # Some file permissions
      file { '/etc/iked.conf' :
        owner   => root,
        group   => wheel,
        mode    => '0600',
        replace => false,
        source  => 'puppet:///modules/base/OpenBSD/iked.conf.sample',
      }
      
      file { '/etc/mail/secrets' :
        owner   => root,
        group   => _smtpd,
        mode    => '0640',
        replace => false,
        content => "Managed from puppet\n",
      }
      
      file { '/etc/mail/secrets.db' :
        owner   => root,
        group   => _smtpd,
        mode    => '0640',
        replace => false,
        content => "Managed from puppet\n",
      }

      # Profile directory
      file { '/etc/profile' :
        owner  => root,
        group  => wheel,
        mode   => '0644',
        source => 'puppet:///modules/base/OpenBSD/profile',
      }

      file { '/etc/profile.d' :
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
      file { '/etc/profile.d/local-vault.sh' :
        owner   => root,
        group   => wheel,
        mode    => '0644',
        content => template('base/local-vault.sh.erb'),
        require => File['/etc/profile.d'],
      }

    }

    'FreeBSD' : {
      # NTP
      class { '::ntp' :
        servers => [ $ntp_servers ],
      }

      $unbound_path = '/usr/local/etc/unbound'

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

    }

    'Debian', 'Ubuntu' : {
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
 
    }

    'Archlinux' : {
      
      $unbound_path = '/etc/unbound'
      
      package { 'cronie' :
        ensure => installed,
      }

      service { 'cronie' :
        ensure  => running,
        enable  => true,
        require => Package['cronie'],
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
      
      file { '/etc/vconsole.conf' :
        owner   => root,
        group   => root,
        mode    => '0644',
        content => template('base/Archlinux/vconsole.conf.erb'),
      }

      file { '/etc/locale.conf' :
        owner  => root,
        group  => root,
        mode   => '0644',
        source => 'puppet:///modules/base/Archlinux/locale.conf',
      }

      # Pacman
      file { '/home/aur' :
        ensure => directory,
        owner  => $local_user,
        group  => $local_user,
        mode   => '0755'
      }
      ->
      file { '/home/aur/custompkgs' :
        ensure => directory,
        owner  => $local_user,
        group  => $local_user,
        mode   => '0755'
      }
      ->
      file { '/home/aur/pkgs' :
        ensure => directory,
        owner  => $local_user,
        group  => $local_user,
        mode   => '0755'
      }

      exec { 'create_aur_repo' :
        command => '/usr/bin/repo-add /home/aur/custompkgs/custom.db.tar',
        creates => '/home/aur/custompkgs/custom.db.tar',
        cwd     => '/home/aur/custompkgs',
        require => File['/home/aur/custompkgs'],
      }

      file { '/home/aur/custompkgs/custom.db.tar' :
        owner => $local_user,
        group => $local_user,
        mode  => '0644',
      }
      
      file { '/etc/pacman.conf' :
        owner   => root,
        group   => root,
        mode    => '0644',
        source  => 'puppet:///modules/base/Archlinux/pacman.conf',
        require => File['/home/aur/custompkgs/custom.db.tar'],
      }
      ->
      file { '/etc/pacman.d/mirrorlist' :
        owner  => root,
        group  => root,
        mode   => '0644',
        source => 'puppet:///modules/base/Archlinux/mirrorlist',
      }
      ->
      file { '/etc/pacman.d/options' :
        owner   => root,
        group   => root,
        mode    => '0644',
        content => '',
        replace => false,
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

    default : {
      fail("Not supported on $facts['os']['family']")
    }

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

