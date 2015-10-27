
# Class for the OpenNTPd server

define base::openntpd_server inherits ntpd::service::openbsd {

  class { 'ntpd' :
    settings => [
      'servers pool.ntp.org',
    ],
  }
  Rcconf['ntpd_flags'] {
    value => '"-s"',
  }
}

define base::ntpd_client (

  $ntp_servers = undef,
  
  ) {

  class { 'ntpd' :
    settings => $ntp_servers,
  }
}
