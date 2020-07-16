
# For unattended upgrades
class base::upgrades (

) inherits base {

  case $facts['os']['family'] {

    'Debian', 'Ubuntu' : {

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
    }

    'Alpine' : {

      package { "apk-cron" :
        ensure => installed,
      }
    }

    default : {
      fail("Not supported on $facts['os']['family']")
    }
      
  }
}

  

  
