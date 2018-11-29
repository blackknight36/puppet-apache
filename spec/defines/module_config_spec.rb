require 'spec_helper'
require 'shared_contexts'

describe 'apache::module_config' do
  let(:title) { 'Apache::module_config::test' }

  let(:facts) {{
    :operatingsystem => 'CentOS',
    :osfamily => 'RedHat',
    :selinux => true
  }}

  let(:params) {{
    :name => 'test',
    :ensure => 'present',
    :content => 'Test',
  }}

  it do
    is_expected.to contain_file("/etc/httpd/conf.modules.d/test.conf")
        .with({
          "ensure" => "present",
          "owner" => "root",
          "group" => "root",
          "mode" => "0644",
          "seluser" => "system_u",
          "selrole" => "object_r",
          "seltype" => "httpd_config_t",
          "content" => 'Test',
        })
        .that_requires('Package[httpd]')
        .that_comes_before('Service[httpd]')
        .that_notifies('Service[httpd]')
  end

end
