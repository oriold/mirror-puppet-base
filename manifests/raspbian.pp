
# For raspbian hosts

class base::raspbian (

){

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
