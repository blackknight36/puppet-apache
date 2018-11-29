# == Class: apache::ssl_site_config
#
# Creates an apache virtual host and manages TLS certificates for a TLS enabled site.
#
# === Parameters
#
# ==== Optional
#
# [*ensure*]
#   Instance is to be 'present' (default) or 'absent'.
#
# [*site_name*]
#   Name of the apache virtual host.  Defaults to the resource namevar.
#
# [*source*]
#   Puppet URL for the file resource.
#
# [*content*]
#   Literal content of the configuration file.  This may be passed from a template.
#
# [*site_number*]
#   This paramter controls the order that vhost configuration files are loaded by apache.
#   Default value is '01' which causes the site to be configured as the default SSL vhost.
#
# [*conf_template*]
#   Path to the template of the vhost configuration file.  Default is undefined.
#   This template will be evaulated within the scope of the apache module.
#
# [*public_key*]
#   Literal content of the TLS public key.  Default value will be looked up in hiera.
#
# [*private_key*]
#   Literal content of the TLS private key. Default value will be looked up in hiera.
#
# [*self_signed_certificate*]
#   Boolean value to determine if the certificate is self-signed.
#   Default is false, i.e. cert should be signed by a trusted authority.
#
# [*service_port*]
#   Port that the service runs on.  Default is undefined.
#
# === Usage
#
#    apache:ssl_site_config { 'host.dartcontainer.com':
#        site_name     => 'vhost.dartcontainer.com',
#        site_number   => '02',
#        conf_template => 'apache/ssl/ssl.conf.erb',
#    }
#
# === Authors
#
#   Michael Watters <michael.watters@dart.biz>
#
# === Copyright
#
# Copyright 2018 Dart Container


define apache::ssl_site_config (
    String $ensure = 'present',
    String $site_name = $name,
    String $site_number = '01',
    String $public_key = lookup("apache.ssl_site_config.\"${site_name}\".public_key"),
    String $private_key = lookup("apache.ssl_site_config.\"${site_name}\".private_key"),
    Boolean $self_signed_certificate = false,
    Optional[String] $service_port = undef,
    Optional[String] $source = undef,
    Optional[String] $content = undef,
    Optional[String] $conf_template = undef,
    ) {

    include 'apache'

    if $content {
        $conf_content = $content
    }

    elsif $conf_template {
        $conf_content = template($conf_template)
    }

    file {
        default:
            notify    => Service[$apache::services],
            require   => Package[$apache::packages],
            show_diff => false,
        ;

        "/etc/pki/tls/certs/${site_name}.crt":
            ensure    => file,
            owner     => 'root',
            group     => 'apache',
            mode      => '0440',
            seltype   => 'cert_t',
            selrole   => 'object_r',
            seluser   => 'system_u',
            content   => $public_key,
        ;

        "/etc/pki/tls/private/${site_name}.key":
            ensure    => file,
            owner     => 'root',
            group     => 'apache',
            mode      => '0440',
            seltype   => 'cert_t',
            selrole   => 'object_r',
            seluser   => 'system_u',
            content   => $private_key,
        ;

        "${apache::include_dir}/${site_number}-${site_name}.ssl.conf":
            ensure    => $ensure,
            owner     => 'root',
            group     => 'root',
            mode      => '0640',
            seluser   => 'system_u',
            selrole   => 'object_r',
            seltype   => 'httpd_config_t',
            source    => $source,
            content   => $conf_content,
        ;
    }

}
