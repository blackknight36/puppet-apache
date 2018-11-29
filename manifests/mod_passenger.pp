# modules/apache/manifests/mod_passenger.pp
#
# == Class: apache::mod_passenger
#
# Configures the Apache web server to provide Phusion Passenger support.
#
# === Parameters
#
# NONE
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#   Michael Watters <michael.watters@dart.biz>

class apache::mod_passenger (
    Array[String] $packages = [],
    ) {

    include 'apache'

    package { $packages:
        ensure => installed,
        notify => Service[$apache::services],
    }

}
