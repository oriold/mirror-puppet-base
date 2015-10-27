
# Class for the OpenNTPd server

class ntpd_server inherits ntpd::service::openbsd {
  class { 'ntpd' :
    settings => [
      'servers pool.ntp.org',
    ],
  }
  Rcconf['ntpd_flags'] {
    value => '"-s"',
  }
}

class ntpd_client {
  class { 'ntpd' :
    settings => $ntp_servers,
  }
}
