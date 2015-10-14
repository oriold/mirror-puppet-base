
# Este es el módulo base con mi usuario, paquetes que quiera instalar, etc.

class base (

  ) {

  # Paquetes
  package { [
    'rsync', 'ccze', 'zsh', 'git', 'mc', 'aide', 'curl', 'gnupg', 'ncdu', 'nmap', 'p7zip',
    'smartmontools', 'unzip', 'unrar', 'wget', 'ranger', 'sudo', 'pwgen', 'mmv', 'lsof',
    'colordiff',
  ] :
    ensure => present,
  }

  if $::operatingsystem == 'OpenBSD' {
    package { [ 'colorls', 'findutils', 'gtar', 'p7zip-rar' ] :
      ensure => present,
    }
  }
  
}
  
