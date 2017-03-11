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
#   Michael Watters <wattersm@watters.ws>

class apache::mod_passenger (
    Optional[Array[String]] $packages = undef,
    ) {

    package { $packages:
        ensure => installed,
        notify => Service[$apache::services],
    }

}
