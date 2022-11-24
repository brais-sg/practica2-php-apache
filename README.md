# practica2-proyectobravo
En este proyecto vamos a crear un servidor web que soporte PHP, además de un DNS y posiblemente una base de datos MySQL

# Creación del fichero docker-compose.yml
Para este sistema vamos a usar la imagen ```php:7.4-apache``` de docker hub, que nos trae un servidor Apache (httpd) además del intérprete de PHP instalado,
para esto, creamos el docker-compose.yml y añadimos las siguientes líneas a servicios

```yml
services:
  apache:
    container_name: asir_apache_php
    image: php:7.4-apache
```

# Mapeando el ```DocumentRoot``` de Apache hacia nuestro directorio donde almacenaremos los ficheros web
Para esto, nos vamos al docker-compose.yml y mapeamos la siguiente ruta:
```yml
volumes:
      - ./site1:/var/www/html
```

Esto nos montará la carpeta ```/var/www/html``` del contenedor sobre nuestro directorio local ```site1``` (Nota importante: No olvidarse del ./)
De esta forma, el servidor tendrá los ficheros web en el directorio de este sitio.

# Creación del HTML y PHP
Crearemos un HTML simple llamado ```index.html``` que contiene el siguiente código:
```html
<!DOCTYPE html>
<html>
    <head><title>Hola sitio 1</title></head>
    <body>Hola sitio 1!</body>
</html>
```

Esto mostrará un Hola sitio 1 al acceder a la dirección del servidor web

Ahora, crearemos un PHP llamado info.php, con el siguiente código
```php
<?php
    echo "Hola mundo desde PHP";
    phpinfo();
?>
```

Esto mostrará un mensaje de Hola mundo desde PHP, además de información sobre el servidor llamado a la función ```phpinfo()```

![info.php](https://raw.githubusercontent.com/brais-sg/practica2-proyectobravo/main/images/phpinfo.png)

# Creación de sitios virtuales

Añadimos un nuevo fichero a ```sites-enabled``` y ```sites-available``` que incluya la siguiente información
```
<VirtualHost *:8080>
	# The ServerName directive sets the request scheme, hostname and port that
	# the server uses to identify itself. This is used when creating
	# redirection URLs. In the context of virtual hosts, the ServerName
	# specifies what hostname must appear in the request's Host: header to
	# match this virtual host. For the default virtual host (this file) this
	# value is not decisive as it is used as a last resort host regardless.
	# However, you must set it for any further virtual host explicitly.
	#ServerName www.example.com

	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/html/site2

	# Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
	# error, crit, alert, emerg.
	# It is also possible to configure the loglevel for particular
	# modules, e.g.
	#LogLevel info ssl:warn

	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined

	# For most configuration files from conf-available/, which are
	# enabled or disabled at a global level, it is possible to
	# include a line for only one particular virtual host. For example the
	# following line enables the CGI configuration for this host only
	# after it has been globally disabled with "a2disconf".
	#Include conf-available/serve-cgi-bin.conf
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
```

Como podemos ver, apuntamos el ```DocumentRoot``` hacia el la raíz de donde guardaremos el otro sitio web


# Instalación de bind9
Basándose el la práctica anterior, integramos en el ```docker-compose``` el servicio bind9, así como configurando la red para asignarle unas direcciones IP estáticas a tanto el servidor DNS como el servidor apache. Para ello añadimos:
```yml
bind9:
    container_name: asir_bind9
    image: internetsystemsconsortium/bind9:9.16
    networks:
      bind9_subnet:
        ipv4_address: 10.1.0.254
    volumes:
      - ./dns/conf:/etc/bind
      - ./dns/zonas:/var/lib/bind
networks:
  bind9_subnet:
    external: true
```


# Habilitación de SSL
Para esto debemos ejecutar una shell en la máquina de Apache y ejecutar ```a2enmod ssl```
tras este comando, habilitaremos SSL en el servidor. Debemos modificar el default-ssl.conf con estos valores
```conf
<IfModule mod_ssl.c>
	<VirtualHost _default_:443>
		ServerAdmin webmaster@localhost

		DocumentRoot /var/www/html

		# Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
		# error, crit, alert, emerg.
		# It is also possible to configure the loglevel for particular
		# modules, e.g.
		#LogLevel info ssl:warn

		ErrorLog ${APACHE_LOG_DIR}/error.log
		CustomLog ${APACHE_LOG_DIR}/access.log combined

		# For most configuration files from conf-available/, which are
		# enabled or disabled at a global level, it is possible to
		# include a line for only one particular virtual host. For example the
		# following line enables the CGI configuration for this host only
		# after it has been globally disabled with "a2disconf".
		#Include conf-available/serve-cgi-bin.conf

		#   SSL Engine Switch:
		#   Enable/Disable SSL for this virtual host.
		SSLEngine on

		#   A self-signed (snakeoil) certificate can be created by installing
		#   the ssl-cert package. See
		#   /usr/share/doc/apache2/README.Debian.gz for more info.
		#   If both key and certificate are stored in the same file, only the
		#   SSLCertificateFile directive is needed.
		SSLCertificateFile	/etc/ssl/certs/ssl-cert-snakeoil.pem
		SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key

		#   Server Certificate Chain:
		#   Point SSLCertificateChainFile at a file containing the
		#   concatenation of PEM encoded CA certificates which form the
		#   certificate chain for the server certificate. Alternatively
		#   the referenced file can be the same as SSLCertificateFile
		#   when the CA certificates are directly appended to the server
		#   certificate for convinience.
		#SSLCertificateChainFile /etc/apache2/ssl.crt/server-ca.crt

		#   Certificate Authority (CA):
		#   Set the CA certificate verification path where to find CA
		#   certificates for client authentication or alternatively one
		#   huge file containing all of them (file must be PEM encoded)
		#   Note: Inside SSLCACertificatePath you need hash symlinks
		#		 to point to the certificate files. Use the provided
		#		 Makefile to update the hash symlinks after changes.
		#SSLCACertificatePath /etc/ssl/certs/
		#SSLCACertificateFile /etc/apache2/ssl.crt/ca-bundle.crt

		#   Certificate Revocation Lists (CRL):
		#   Set the CA revocation path where to find CA CRLs for client
		#   authentication or alternatively one huge file containing all
		#   of them (file must be PEM encoded)
		#   Note: Inside SSLCARevocationPath you need hash symlinks
		#		 to point to the certificate files. Use the provided
		#		 Makefile to update the hash symlinks after changes.
		#SSLCARevocationPath /etc/apache2/ssl.crl/
		#SSLCARevocationFile /etc/apache2/ssl.crl/ca-bundle.crl

		#   Client Authentication (Type):
		#   Client certificate verification type and depth.  Types are
		#   none, optional, require and optional_no_ca.  Depth is a
		#   number which specifies how deeply to verify the certificate
		#   issuer chain before deciding the certificate is not valid.
		#SSLVerifyClient require
		#SSLVerifyDepth  10

		#   SSL Engine Options:
		#   Set various options for the SSL engine.
		#   o FakeBasicAuth:
		#	 Translate the client X.509 into a Basic Authorisation.  This means that
		#	 the standard Auth/DBMAuth methods can be used for access control.  The
		#	 user name is the `one line' version of the client's X.509 certificate.
		#	 Note that no password is obtained from the user. Every entry in the user
		#	 file needs this password: `xxj31ZMTZzkVA'.
		#   o ExportCertData:
		#	 This exports two additional environment variables: SSL_CLIENT_CERT and
		#	 SSL_SERVER_CERT. These contain the PEM-encoded certificates of the
		#	 server (always existing) and the client (only existing when client
		#	 authentication is used). This can be used to import the certificates
		#	 into CGI scripts.
		#   o StdEnvVars:
		#	 This exports the standard SSL/TLS related `SSL_*' environment variables.
		#	 Per default this exportation is switched off for performance reasons,
		#	 because the extraction step is an expensive operation and is usually
		#	 useless for serving static content. So one usually enables the
		#	 exportation for CGI and SSI requests only.
		#   o OptRenegotiate:
		#	 This enables optimized SSL connection renegotiation handling when SSL
		#	 directives are used in per-directory context.
		#SSLOptions +FakeBasicAuth +ExportCertData +StrictRequire
		<FilesMatch "\.(cgi|shtml|phtml|php)$">
				SSLOptions +StdEnvVars
		</FilesMatch>
		<Directory /usr/lib/cgi-bin>
				SSLOptions +StdEnvVars
		</Directory>

		#   SSL Protocol Adjustments:
		#   The safe and default but still SSL/TLS standard compliant shutdown
		#   approach is that mod_ssl sends the close notify alert but doesn't wait for
		#   the close notify alert from client. When you need a different shutdown
		#   approach you can use one of the following variables:
		#   o ssl-unclean-shutdown:
		#	 This forces an unclean shutdown when the connection is closed, i.e. no
		#	 SSL close notify alert is send or allowed to received.  This violates
		#	 the SSL/TLS standard but is needed for some brain-dead browsers. Use
		#	 this when you receive I/O errors because of the standard approach where
		#	 mod_ssl sends the close notify alert.
		#   o ssl-accurate-shutdown:
		#	 This forces an accurate shutdown when the connection is closed, i.e. a
		#	 SSL close notify alert is send and mod_ssl waits for the close notify
		#	 alert of the client. This is 100% SSL/TLS standard compliant, but in
		#	 practice often causes hanging connections with brain-dead browsers. Use
		#	 this only for browsers where you know that their SSL implementation
		#	 works correctly.
		#   Notice: Most problems of broken clients are also related to the HTTP
		#   keep-alive facility, so you usually additionally want to disable
		#   keep-alive for those clients, too. Use variable "nokeepalive" for this.
		#   Similarly, one has to force some clients to use HTTP/1.0 to workaround
		#   their broken HTTP/1.1 implementation. Use variables "downgrade-1.0" and
		#   "force-response-1.0" for this.
		# BrowserMatch "MSIE [2-6]" \
		#		nokeepalive ssl-unclean-shutdown \
		#		downgrade-1.0 force-response-1.0

	</VirtualHost>
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
```

Ahora, vamos a generar los certificados usando el siguiente comando:
```bash
mkdir /etc/apache2/certificate
cd /etc/apache2/certificate
openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out apache-certificate.crt -keyout apache.key
```

Una vez generados los certificados, se modificará el fichero ```default-ssl.conf``` en consecuencia, dado a que tenemos que darle
la ruta de donde se encuentran nuestros certificados
```conf
SSLCertificateFile	/etc/apache2/certificate/apache-certificate.crt
SSLCertificateKeyFile /etc/apache2/certificate/apache.key
```

Dados estos pasos, y acordándonos de añadir el puerto 433 al fichero ```docker-compose.yml``` tendremos iniciado el servidor escuchando en el puerto
443