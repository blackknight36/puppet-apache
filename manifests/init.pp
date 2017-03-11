# modules/apache/manifests/init.pp
#
# == Class: apache
#
# Configures a host to provide an Apache web server.
#
# === Parameters
#
# [*anon_write*]
#   Configure SE Linux to allow httpd to modify public files used for public
#   file tranfer services.  One of: true or false (default).
#
# [*network_connect*]
#   Configure SE Linux to allow httpd scripts and modules to connect to the
#   network using TCP.  One of: true or false (default).
#
# [*network_connect_db*]
#   Configure SE Linux to allow httpd scripts and modules to connect to
#   databases over the network.  One of: true or false (default).
#
# [*use_nfs*]
#   Configure SE Linux to allow the serving content reached via NFS.  One of:
#   true or false (default).
#
# [*manage_firewall*]
#   If true, open the HTTP port on the firewall.  Otherwise the firewall is
#   left unaffected.  Defaults to true.
#
# [*server_admin*]
#   The email address to where problems with the server should be sent.  This
#   address appears on some server-generated pages, such as error documents.
#   Defaults to "root@localhost".
#
# [*conf_dir*]
#   The directory where apache configuration files are stored.  Defaults
#   to /etc/apache.
#
# [*include_dir*]
#   Drop in directory for apache include files.  Any files placed in this directory
#   will be processed in alpha-numerical order.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#   Michael Watters <wattersm@watters.ws>

class apache (
    Optional[Array[String]] $packages = undef,
    Optional[Array[String]] $services = undef,
    Boolean $anon_write = false,
    Boolean $network_connect = false,
    Boolean $network_connect_db = false,
    Boolean $use_nfs = false,
    Boolean $manage_firewall = true,
    String $server_admin = 'root@localhost',
    String $conf_dir = '/etc/apache',
    String $conf_file = '/etc/apache/apache.conf',
    String $include_dir = '/etc/apache/conf.d',
    ) {

    File {
        owner       => 'root',
        group       => 'wheel',
        mode        => '0640',
        seluser     => 'system_u',
        selrole     => 'object_r',
        seltype     => 'httpd_config_t',
        before      => Service[$services],
        notify      => Service[$services],
        subscribe   => Package[$packages],
    }

    case $::operatingsystem {
        'Fedora': {
            if $::operatingsystemrelease < '18' {
                $bool_anon_write = 'allow_httpd_anon_write'
            }

            else {
                $bool_anon_write = 'httpd_anon_write'
            }

            $bool_can_network_connect = 'httpd_can_network_connect'
            $bool_can_network_connect_db = 'httpd_can_network_connect_db'
            $bool_use_nfs = 'httpd_use_nfs'
        }

        'CentOS': {
            $bool_anon_write = 'httpd_anon_write'
            $bool_can_network_connect = 'httpd_can_network_connect'
            $bool_can_network_connect_db = 'httpd_can_network_connect_db'
            $bool_use_nfs = 'httpd_use_nfs'
        }

        default: {}
    }

    package { $packages:
        ensure => installed,
        notify => Service[$services],
    }

    file { $conf_file:
        content => template("apache/httpd.conf.${::operatingsystem}.${::operatingsystemrelease}"),
    }

    if $manage_firewall == true and $::kernel == 'Linux' {
        firewall { '080 apache http':
            dport  => 80,
            proto  => tcp,
            action => accept,
        }
    }

    if $::selinux == true {

        Selboolean {
            persistent => true,
            before     => Service[$services],
        }

        selboolean {
            $bool_anon_write:
                value => $anon_write ? {
                    true    => 'on',
                    default => 'off',
                };

            $bool_can_network_connect:
                value => $network_connect ? {
                    true    => 'on',
                    default => 'off',
                };

            $bool_can_network_connect_db:
                value => $network_connect_db ? {
                    true    => 'on',
                    default => 'off',
                };

            $bool_use_nfs:
                value => $use_nfs ? {
                    true    => 'on',
                    default => 'off',
                };
        }
    }

    service { $services:
        ensure     => running,
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
    }

}
