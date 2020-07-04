
# For ArtixLinux
class base::artixlinux (

) inherits base {

  Package { provider => 'pacman' }
  Service { provider => 'openrc' }
  
  $unbound_path = '/etc/unbound'

  # Paquetes
  package { [ $base_packages, $local_packages ] :
    ensure => installed,
  }
  
  package { 'cronie-openrc' :
    ensure   => installed,
  }

  service { 'cronie' :
    ensure  => running,
    enable  => true,
    require => Package['cronie-openrc'],
  }

  package { 'openntpd-openrc' :
    ensure => installed,
  }

  service { 'openntpd' :
    ensure  => running,
    enable  => true,
    require => Package['openntpd-openrc'],
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
  zfs { 'zroot/home/aur' :
    ensure => present,
  }
  ->
  file { '/home/aur' :
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
    source  => 'puppet:///modules/base/Artixlinux/pacman.conf',
    require => File['/home/aur/custompkgs/custom.db.tar'],
  }
  ->
  file { '/etc/pacman.d/mirrorlist' :
    owner  => root,
    group  => root,
    mode   => '0644',
    source => 'puppet:///modules/base/Artixlinux/mirrorlist',
  }
  ->
  file { '/etc/pacman.d/mirrorlist-arch' :
    owner  => root,
    group  => root,
    mode   => '0644',
    source => 'puppet:///modules/base/Artixlinux/mirrorlist-arch',
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

  # SSH
  package { 'openssh-openrc':
    ensure => present,
  }
  
  service { $ssh_service :
    ensure => running,
  }

}  
