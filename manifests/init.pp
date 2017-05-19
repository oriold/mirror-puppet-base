# Basic module
class base (

  $base_packages    = undef,
  $debian_packages  = undef,
  $freebsd_packages = undef,
  $ntp_master       = undef,
  $ntp_servers      = undef,
  $openbsd_mirror   = undef,
  $openbsd_packages = undef,
  $openbsd_version  = undef,
  $ssh_allow_groups = undef,

  ){

  # Hiera
  $ssh_service = hiera('ssh_service')
  $ssl_dir     = hiera('ssl_dir')

  # Paquetes
  if $::operatingsystem == 'OpenBSD' {

    service { 'apmd' :
      ensure => running,
      enable => true,
    }

    service { 'ntpd' :
      ensure => running,
      enable => true,
    }

    exec { 'apmd_flags' :
      command => 'rcctl set apmd flags -A',
      path    => '/usr/local/bin:/usr/bin:/bin:/sbin:/usr/sbin',
      notify  => Service['apmd'],
    }

    # OpenNTPd server
    if $ntp_master {
      $ntp_template = 'openbsd.ntpd_server.conf.erb'

      exec { 'ntpd_flags' :
        command => 'rcctl set ntpd flags -s',
        path    => '/usr/local/bin:/usr/bin:/bin:/sbin:/usr/sbin',
        notify  => Service['apmd'],
      }
      
    } else {
      $ntp_template = 'openbsd.ntpd.conf.erb'
    }

    file { '/etc/ntpd.conf' :
      owner   => root,
      group   => wheel,
      mode    => '0644',
      content => template("base/${ntp_template}"),
      notify  => Service['ntpd'],
    }

    file { '/etc/installurl' :
      owner => root,
      group => wheel,
      mode  => '0644',
      content => "http://${openbsd_mirror}\n",
    }

    file { '/etc/pkg.conf' :
      ensure => link,
      target => '/etc/installurl',
    }

    file { '/etc/signify/mtier-60-pkg.pub' :
      owner  => root,
      group  => wheel,
      mode   => '0644',
      source => 'puppet:///modules/base/mtier-60-pkg.pub',
      } ->
      package { [ $base_packages, $openbsd_packages ] :
        ensure => installed,
      }

      # Ports configuration
      file { '/etc/mk.conf' :
        owner  => root,
        group  => wheel,
        mode   => '0644',
        source => 'puppet:///modules/base/openbsd.mk.conf',
      }

      # KSH configuration
      file { '/etc/ksh.kshrc' :
        owner  => root,
        group  => wheel,
        mode   => '0644',
        source => 'puppet:///modules/base/ksh.kshrc',
      }

      file { '/etc/skel/.kshrc' :
        owner  => root,
        group  => wheel,
        mode   => '0644',
        source => 'puppet:///modules/base/skel.kshrc',
      }

  }

  if $::operatingsystem == 'FreeBSD' {
    package { [ $base_packages, $freebsd_packages ] :
      ensure => installed,
    }

    # NTP
    class { '::ntp' :
      servers => [ $ntp_servers ],
    }

  }

  if $::operatingsystem == 'Debian' {
    package { [ $base_packages, $debian_packages ] :
      ensure => installed,
    }

    # NTP
    class { '::ntp' :
      servers => [ $ntp_servers ],
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
  } ->
  file { '/etc/unbound/root.key' :
    owner  => root,
    group  => 0,
    mode   => '0644',
    source => 'puppet:///modules/base/unbound.root.key',
  }

  # SSL
  file { [ '/dhparam.pem',
      '/dhparam-4096.pem',
  ] :
      ensure => absent,
  }

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

