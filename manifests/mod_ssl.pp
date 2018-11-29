# modules/apache/manifests/mod_ssl.pp
#
# == Class: apache::mod_ssl
#
# Configures the Apache web server to provide mod_ssl (HTTPS) support.
#
# === Parameters
#
# [*manage_firewall*]
#   If true, open the HTTPS port on the firewall.  Otherwise the firewall is
#   left unaffected.  Defaults to true.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#   Michael Watters <michael.watters@dart.biz>

class apache::mod_ssl (
    Array[String] $packages = ['mod_ssl'],
    Boolean $manage_firewall = true,
    ) {

    include 'apache'

    package { $packages:
        ensure => installed,
        notify => Service[$apache::services],
    }

    if $manage_firewall == true {
        firewall { '101 allow https':
            dport  => 443,
            proto  => tcp,
            action => accept,
        }
    }
}
