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
#   Michael Watters <michael.watters@dart.biz>

class apache::mod_wsgi (
    Array[String] $packages = [],
    ) {

    include 'apache'

    package { $packages:
        ensure => installed,
        notify => Service[$apache::services],
    }

}
