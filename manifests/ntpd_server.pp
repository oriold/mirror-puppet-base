
class base::ntpd_server inherits ntpd::service::openbsd {
  class { 'ntpd':
    settings => [
      "listen on *",
      "servers pool.ntp.org",
    ],
  }
}
