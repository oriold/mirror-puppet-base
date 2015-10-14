
# Este es el módulo base con mi usuario, paquetes que quiera instalar, etc.

class base (

  ) {

  # Paquetes
  package { [
    "rsync",
  ] :
    ensure => present,
  }

}
  
