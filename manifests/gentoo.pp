# For Gentoo
class base::gentoo (
  $common_flags         = undef,
  $l10n                 = undef,
  $makeopts             = undef,
  $mirrors              = undef,
  $ruby_targets         = undef,
  $python_single_target = undef,
  $python_targets       = undef,
  $uefi_boot            = undef,
  $umask                = 'umask 027',
  $use                  = undef,
  $video_cards          = undef,
  $zfs_pool             = 'zroot',
  $zfs_keep_hourly      = '8',
  $zfs_keep_daily       = '7',
  $zfs_keep_weekly      = '4',
  $zfs_keep_monthly     = '3',

) inherits base {

  # Paquetes
  file { '/etc/portage/make.conf' :
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('base/Gentoo/make.conf.erb'),
  }

  file { '/etc/portage/package.accept_keywords' :
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }
  ->
  file { '/etc/portage/package.accept_keywords/zz-autounmask' :
    owner   => root,
    group   => root,
    mode    => '0644',
    content => '#package.accept_keywords#',
  }

  file { '/etc/portage/env' :
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }
  ->
  file { [ '/etc/portage/env/civ5fix', '/etc/portage/env/monerofix' ] :
    ensure => absent,
  }

  file { '/etc/portage/package.env' :
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }
  
  file { '/etc/portage/package.license' :
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }
  ->
  file { '/etc/portage/package.license/kernel' :
    owner  => root,
    group  => root,
    mode   => '0644',
    source => 'puppet:///modules/base/Gentoo/license.kernel',
  }
  ->
  file { '/etc/portage/package.license/zz-autounmask' :
    owner   => root,
    group   => root,
    mode    => '0644',
    content => '#package.license#',
  }

  file { '/etc/portage/package.use' :
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }
  ->
  file { '/etc/portage/package.use/zz-autounmask' :
    owner   => root,
    group   => root,
    mode    => '0644',
    content => '#package.use#',
  }

  file { '/etc/conf.d/keymaps' :
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('base/Gentoo/keymaps.erb'),
  }

  file { '/etc/env.d/02locale' :
    owner  => root,
    group  => root,
    mode   => '0644',
    source => 'puppet:///modules/base/Gentoo/02locale',
  }
  
  package { $local_packages :
    ensure => installed,
  }

  package { 'sys-process/cronie' :
    ensure => installed,
  }

  service { 'cronie' :
    ensure  => running,
    enable  => true,
    require => Package['sys-process/cronie'],
  }

  package { 'app-admin/sysklogd' :
    ensure => installed,
  }

  service { 'sysklogd' :
    ensure  => running,
    enable  => true,
    require => Package['app-admin/sysklogd'],
  }

  package { 'net-misc/openntpd' :
    ensure => installed,
  }

  service { 'ntpd' :
    ensure  => running,
    enable  => true,
    require => Package['net-misc/openntpd'],
  }

  file { '/etc/ntpd.conf' :
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('base/ntpd.conf.erb'),
    notify  => Service['ntpd'],
  }

  file { '/var/db/geoip' :
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }

  # ZFS
  file { '/etc/cron.weekly/zfs-scrub' :
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('base/Gentoo/zfs-scrub.erb'),
  }

  file { '/etc/cron.hourly/zfs-auto-snapshot' :
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('base/Gentoo/zfs-autosnapshot-hourly.erb'),
  }

  file { '/etc/cron.daily/zfs-auto-snapshot' :
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('base/Gentoo/zfs-autosnapshot-daily.erb'),
  }

  file { '/etc/cron.weekly/zfs-auto-snapshot' :
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('base/Gentoo/zfs-autosnapshot-weekly.erb'),
  }

  file { '/etc/cron.monthly/zfs-auto-snapshot' :
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('base/Gentoo/zfs-autosnapshot-monthly.erb'),
  }
  
  # Change umask
  file_line { 'change_umask' :
    path  => '/etc/profile',
    line  => $umask,
    match => '^umask',
  }

  # Vault
  file { '/etc/profile.d/local-vault.sh' :
    owner   => root,
    group   => wheel,
    mode    => '0644',
    content => template('base/local-vault.sh.erb'),
  }

}
