
# For raspbian hosts

class base::raspbian (

){

  package { "unattended-upgrades" :
    ensure => installed,
  }

  file { "/etc/apt/apt.conf.d/20auto-upgrades" :
    owner  => root,
    group  => root,
    mode   => '0644',
    source => 'puppet:///modules/base/Raspbian/20auto-upgrades',
  }

  file { "/etc/apt/apt.conf.d/50unattendedupgrades" :
    owner  => root,
    group  => root,
    mode   => '0644',
    source => 'puppet:///modules/base/Raspbian/50unattendedupgrades',
  }

  file { "/etc/sudoers" :
    owner  => root,
    group  => root,
    mode   => '0440',
    source => 'puppet:///modules/base/Raspbian/sudoers',
  }

  file { "/usr/local/bin/vault" :
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/base/Raspbian/vault',
  }
  
}
