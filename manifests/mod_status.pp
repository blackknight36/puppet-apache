# modules/apache/manifests/mod_status.pp
#
# == Class: apache::mod_status
#
# Configures the Apache server status page.
#
# === Parameters
#
# === Authors
#
#   Michael Watters <michael.watters@dart.biz>

class apache::mod_status (
    ) {

    include 'apache'

    file { "${apache::include_dir}/mod_status.conf":
        source  => 'puppet:///modules/apache/mod_status.conf',
        notify  => Service[$apache::services],
        require => Package[$apache::packages],
    }

}
