# == Class: apache::ssl_site
#
# Configures SSL virtual host and certificate files for
# a specific SSL site
#
# === Parameters
#
# ==== Optional
#
# [*ensure*]
#   Instance is to be 'present' (default) or 'absent'.
#
# [*manage_firewall*]
#   Manage firewall rules to allow https access.  Defaults to true.
#
# [*site_name*]
#   Name of the apache virtual host.  Defaults to the server's FQDN.
#
# === Usage
#
#    apache:ssl_site_config {
#        site_name => 'host.dartcontainer.com',
#    }
#
# === Authors
#
#   Michael Watters <wattersm@watters.ws>

define apache::ssl_site_config (
    Optional[String] $ensure = 'present',
    Optional[Boolean] $manage_firewall = true,
    Optional[String] $site_name = $::fqdn,
    Optional[String] $source = undef,
    Optional[String] $content = undef,
    ) {

    File {
        notify => Service[$apache::services],
    }

    file { "${apache::ssl_cert_dir}/${site_name}.crt":
            ensure    => file,
            show_diff => false,
            owner     => 'root',
            group     => 'apache',
            mode      => '0440',
            seltype   => 'cert_t',
            selrole   => 'object_r',
            seluser   => 'system_u',
            source    => "puppet:///modules/files/private/${::fqdn}/apache/ssl/${site_name}.crt",
    } ->

    file { "${apache::ssl_private_dir}/${site_name}.key":
        ensure    => file,
        show_diff => false,
        owner     => 'root',
        group     => 'apache',
        mode      => '0440',
        seltype   => 'cert_t',
        selrole   => 'object_r',
        seluser   => 'system_u',
        source    => "puppet:///modules/files/private/${::fqdn}/apache/ssl/${site_name}.key",
    }

    apache::site_config { "${site_name}.ssl":
        source  => $source,
        content => $content,
    }

}
