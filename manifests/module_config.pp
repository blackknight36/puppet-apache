# modules/apache/manifests/module_config.pp
#
# == Define: apache::module_config
#
# Installs a module configuration file for the Apache HTTP server.
#
# === Parameters
#
# [*namevar*]
#   Instance name, e.g., "99-prefork".  Include neither path, nor '.conf'
#   extension.  These typically have a two-digit prefix for priority
#   sequencing.
#
# [*ensure*]
#   Instance is to be 'present' (default) or 'absent'.
#
# [*content*]
#   Literal content for the module_config file.  One and only one of "content"
#   or "source" must be given.
#
# [*source*]
#   URI of the module_config file content.  One and only one of "content" or
#   "source" must be given.
#
# === Authors
#
#   John Florian <john.florian@dart.biz>
#   Michael Watters <michael.watters@dart.biz>

define apache::module_config (
    Optional[String] $source = undef,
    Optional[String] $content = undef,
    String $ensure = 'present',
    ) {

    include 'apache'

    file { "${apache::module_include_dir}/${name}.conf":
        ensure  => $ensure,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        seluser => 'system_u',
        selrole => 'object_r',
        seltype => 'httpd_config_t',
        source  => $source,
        content => $content,
        require => Package[$apache::packages],
        before  => Service[$apache::services],
        notify  => Service[$apache::services],
    }

}
