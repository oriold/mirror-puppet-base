
# For raspbian hosts

class base::raspbian (

){

  package { [ "update-notifier-common", "unattended-upgrades" ] :
    ensure => installed,
  }

  file { "/etc/apt/apt.conf.d/21auto-upgrades" :
    owner  => root,
    group  => root,
    mode   => '0644',
    source => 'puppet:///modules/base/Debian/21auto-upgrades',
  }

  file { "/etc/apt/apt.conf.d/60unattendedupgrades" :
    owner  => root,
    group  => root,
    mode   => '0644',
    source => 'puppet:///modules/base/Debian/60unattendedupgrades',
  }
  
}
