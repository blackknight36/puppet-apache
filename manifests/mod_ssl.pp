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
#   Michael Watters <wattersm@watters.ws>

class apache::mod_ssl (
    Optional[Array[String]] $packages = undef,
    Boolean $manage_firewall = true,
    ) {

    package { $packages:
        ensure => installed,
        notify => Service[$apache::services],
    }

    if $manage_firewall and $::kernel == 'Linux' {
        firewall { '081 apache https':
            dport  => 443,
            proto  => tcp,
            action => accept,
        }
    }

}
