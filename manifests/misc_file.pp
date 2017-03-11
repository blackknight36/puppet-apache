# modules/apache/manifests/misc_file.pp
#
# == Define: apache::misc_file
#
# Installs a miscellaneous file for the Apache web server.
#
# === Parameters
#
# [*namevar*]
#   Base name of the file instance.
#
# [*ensure*]
#   Instance is to be 'present' (default) or 'absent'.
#
# [*content*]
#   Literal content for the file.  One and only one of "content" or "source"
#   must be given.
#
# [*source*]
#   URI of the file content.  One and only one of "content" or "source" must
#   be given.
#
# [*owner*]
#   File owner for access controls.  Default is 'root'.
#
# [*group*]
#   File group for access controls.  Default is 'apache'.
#
# [*mode*]
#   File mode for access controls.  Default is '0640'.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#   Michael Watters <wattersm@watters.ws>

define apache::misc_file (
    Optional[String] $ensure = 'present',
    Optional[String] $content = undef,
    Optional[String] $source = undef,
    Optional[String] $owner = 'root',
    Optional[String] $group = 'apache',
    Optional[String] $mode = '0640',
    ) {

    file { "${apache::include_dir}/${name}":
        ensure  => $ensure,
        owner   => $owner,
        group   => $group,
        mode    => $mode,
        seluser => 'system_u',
        selrole => 'object_r',
        seltype => 'httpd_config_t',
        content => $content,
        source  => $source,
        require => Package[$apache::packages],
        notify  => Service[$apache::services],
    }

}
