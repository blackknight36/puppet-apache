# modules/apache/manifests/mod_ldap.pp
#
# == Class: apache::mod_ldap
#
# Configures the Apache web server to provide LDAP authentication via mod_ldap.
#
# === Authors
#
#   Michael Watters <michael.watters@dart.biz>

class apache::mod_ldap (
    Array[String] $packages = ['mod_ldap'],
    ) {

    include 'apache'

    package { $packages:
        ensure => installed,
        notify => Service[$apache::services],
    }
}
