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
#   Michael Watters <wattersm@watters.ws>

class apache::mod_status (
    Optional[Array[String]] $packages = undef,
    Optional[Array[String]] $services = undef,
    ) {

    file { "${apache::include_dir}/mod_status.conf":
        source => 'puppet:///modules/apache/mod_status.conf',
        notify => Service[$apache::services],
    }

}
