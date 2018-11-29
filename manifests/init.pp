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
# [*execmem*]
#  Configure SELinux to allow httpd scripts and modules execmem/execstack
#  True or false.  Default to false.
#
#  [*can_sendmail*]
#  Configure SELinux to allow httpd to send mail.  Default to false
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
# [*conf_file*]
#   The path to the main apache configuration file.  Defaults to /etc/httpd/conf/httpd.conf
#
# [*conf_template*]
#   The path to the template to be used for the apache configuration file.  Defaults
#   to 'apache/httpd.conf.erb'
#
# [*include_dir*]
#   Drop in directory for apache include files.  Any files placed in this directory
#   will be processed in alpha-numerical order.  Defaults to /etc/httpd/conf.d
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#   Michael Watters <michael.watters@dart.biz>

class apache (
    Array[String] $packages = ['httpd'],
    Array[String] $services = ['httpd'],
    Boolean $anon_write = false,
    Boolean $network_connect = false,
    Boolean $network_connect_db = false,
    Boolean $use_nfs = false,
    Boolean $execmem = false,
    Boolean $can_sendmail = false,
    Boolean $manage_firewall = true,
    String $server_admin = 'root@localhost',
    String $conf_dir = '/etc/httpd',
    String $conf_file = '/etc/httpd/conf/httpd.conf',
    String $conf_template = 'apache/httpd.conf.erb',
    String $include_dir = '/etc/httpd/conf.d',
    String $module_include_dir = '/etc/httpd/conf.modules.d',
    ) {

    File {
        owner       => 'root',
        group       => 'root',
        mode        => '0640',
        seluser     => 'system_u',
        selrole     => 'object_r',
        seltype     => 'httpd_config_t',
        before      => Service[$services],
        notify      => Service[$services],
        subscribe   => Package[$packages],
    }

    case $facts['operatingsystem'] {
        'CentOS', 'Fedora': {
            $bool_anon_write = 'httpd_anon_write'
            $bool_can_network_connect = 'httpd_can_network_connect'
            $bool_can_network_connect_db = 'httpd_can_network_connect_db'
            $bool_use_nfs = 'httpd_use_nfs'
            $bool_execmem = 'httpd_execmem'
            $bool_can_sendmail = 'httpd_can_sendmail'
        }

        default: {
            fail("The apache module is not supported on ${facts['operatingsystem']}.")
        }
    }

    package { $packages:
        ensure => installed,
        notify => Service[$services],
    }

    file { $conf_file:
        content => template($conf_template),
    }

    if $manage_firewall == true {
        firewall { '100 allow http':
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

            $bool_execmem:
                value => $execmem ? {
                    true    => 'on',
                    default => 'off',
                };

            $bool_can_sendmail:
                value => $can_sendmail ? {
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
