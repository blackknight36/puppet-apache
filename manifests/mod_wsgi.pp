# modules/apache/manifests/mod_wsgi.pp
#
# == Class: apache::mod_wsgi
#
# Configures the Apache web server to provide mod_wsgi (python) support.
#
# === Parameters
#
# === Authors
#
#   Michael Watters <wattersm@watters.ws>

class apache::mod_wsgi (
    Optional[Array[String]] $packages = undef,
    ) {

    package { $packages:
        ensure => installed,
        notify => Service[$apache::services],
    }

}
