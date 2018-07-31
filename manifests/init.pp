# Basic module
class base (

  $base_packages    = undef,
  $debian_packages  = undef,
  $freebsd_packages = undef,
  $kbd_lang         = 'es',
  $ntp_master       = undef,
  $ntp_servers      = undef,
  $openbsd_apmd     = '-A',
  $openbsd_mirror   = undef,
  $openbsd_packages = undef,
  $openbsd_version  = undef,
  $ssh_allow_groups = undef,

){

  # Hiera
  $ssh_service = hiera('ssh_service')
  $ssl_dir     = hiera('ssl_dir')

  # Paquetes
  case $::operatingsystem {

    'OpenBSD' : {

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

      package { [ $base_packages, $openbsd_packages ] :
        ensure          => installed,
        install_options => '-v',
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
      package { [ $base_packages, $freebsd_packages ] :
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

    }

    'Debian', 'Ubuntu' : {
      package { [ $base_packages, $debian_packages ] :
        ensure => installed,
      }

      # NTP
      class { '::ntp' :
        servers => [ $ntp_servers ],
      }

    }

    default : {
      fail("Not supported on ${::operatingsystem}")
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

  # Dig
  file { '/etc/trusted-key.key' :
    owner  => root,
    group  => 0,
    mode   => '0644',
    source => 'puppet:///modules/base/trusted-key.key',
  }

  file { '/etc/unbound' :
    ensure => directory,
    owner  => root,
    group  => 0,
    mode   => '0755',
  }
  -> file { '/etc/unbound/root.key' :
    owner  => root,
    group  => 0,
    mode   => '0644',
    source => 'puppet:///modules/base/unbound.root.key',
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

