
# Este es el módulo base con mi usuario, paquetes que quiera instalar, etc.

class base (

  $base_packages    = undef,
  $debian_packages  = undef,
  $freebsd_packages = undef,
  $ntp_master       = undef,
  $ntp_servers      = undef,
  $openbsd_mirror   = undef,
  $openbsd_packages = undef,
  $ssh_allow_groups = undef,

  ) {

  # Hiera
  $ssh_service = hiera('ssh_service')

  # OpenNTPd server
  class ntpd_server inherits ntpd::service::openbsd {
    Rcconf['ntpd_flags'] {
      value => '"-s"',
    }
  }
  
  # Paquetes
  if $::operatingsystem == 'OpenBSD' {

    if $::operatingsystemrelease =~ /.*(current|beta)/ {
      class { 'openbsd::pkg_conf' :
        settings => {
          installpath => "http://${openbsd_mirror}/snapshots/packages/${::architecture}/",
          ntogo       => yes,
          loglevel    => 1,
        }
      }
    }
    else {
      class { 'openbsd::pkg_conf' :
        settings => {
          installpath => [
            "http://${openbsd_mirror}/${::operatingsystemrelease}/packages/${::architecture}/",
            "https://stable.mtier.org/updates/${::operatingsystemrelease}/${::architecture}/",
          ],
          ntogo       => yes,
          loglevel    => 1,
        }
      }
    }

    file { [
      '/etc/signify/mtier-58-pkg.pub',
    ] :
      owner  => root,
      group  => wheel,
      mode   => '0644',
      source => 'puppet:///modules/base/mtier-58-pkg.pub',
    } ->
    package { [ $base_packages, $openbsd_packages ] :
      ensure          => installed,
      install_options => '-v',
    }

    # Ports configuration
    file { '/etc/mk.conf' :
      owner  => root,
      group  => wheel,
      mode   => '0644',
      source => 'puppet:///modules/base/openbsd.mk.conf',
    }
    
    # NTP Server
    if $ntp_master {
      class { 'ntpd_server' : }
    }

    # NTP normal
    class { 'ntpd' :
      settings => [
        "servers ${ntp_servers}",
      ],
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
  
}
  
