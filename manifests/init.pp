# Basic module
class base (

  $base_packages    = undef,
  $kbd_lang         = 'es',
  $local_packages   = undef,
  $ntp_master       = undef,
  $ntp_servers      = undef,
  $openbsd_apmd     = '-A',
  $openbsd_mirror   = undef,
  $ssh_allow_groups = undef,

){

  # Hiera
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
      }

      service { 'ntpd' :
        ensure => running,
      }

      exec { 'apmd_flags' :
        command => "rcctl set apmd flags '${openbsd_apmd}'",
        path    => '/usr/local/bin:/usr/bin:/bin:/sbin:/usr/sbin',
        notify  => Service['apmd'],
      }

      # OpenNTPd server
      if $ntp_master {
        $ntp_template = 'ntpd_server.conf.erb'

        exec { 'ntpd_flags' :
          command => "rcctl set ntpd flags '-s'",
          path    => '/usr/local/bin:/usr/bin:/bin:/sbin:/usr/sbin',
          notify  => Service['ntpd'],
        }

      } else {
        $ntp_template = 'ntpd.conf.erb'
      }

      file { '/etc/ntpd.conf' :
        owner   => root,
        group   => wheel,
        mode    => '0644',
        content => template("base/OpenBSD/${ntp_template}"),
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

      file { '/etc/iked/pubkeys/fqdn/gtw-2.the-grid.xyz' :
        owner  => root,
        group  => wheel,
        mode   => '0644',
        source => 'puppet:///modules/base/OpenBSD/gtw-2.the-grid.xyz',
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

    }

    'Debian', 'Ubuntu' : {
      # NTP
      class { '::ntp' :
        servers => [ $ntp_servers ],
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

      file { '/etc/pacman.conf' :
        owner  => root,
        group  => root,
        mode   => '0644',
        source => 'puppet:///modules/base/Archlinux/pacman.conf',
      }
      ->
      file { '/etc/pacman.d/mirrorlist' :
        owner  => root,
        group  => root,
        mode   => '0644',
        source => 'puppet:///modules/base/Archlinux/mirrorlist',
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

      # AUR
      file { '/home/aur' :
        ensure => directory,
        owner  => root,
        group  => wheel,
        mode   => '0775'
      }
      ->
      file { '/home/aur/custompkgs' :
        ensure => directory,
        owner  => root,
        group  => wheel,
        mode   => '0775'
      }
      ->
      file { '/home/aur/pkgs' :
        ensure => directory,
        owner  => root,
        group  => wheel,
        mode   => '0775'
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

}

