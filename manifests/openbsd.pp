
# For OpenBSD
class base::openbsd (

) inherits base {

  # Paquetes
  package { [ $base_packages, $local_packages ] :
    ensure => installed,
  }

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
