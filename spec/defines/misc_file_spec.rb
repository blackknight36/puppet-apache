require 'spec_helper'
require 'shared_contexts'

describe 'apache::misc_file' do
  let(:title) { 'Apache::misc_file::test.conf' }

  let(:facts) {{
    :operatingsystem => 'CentOS',
    :osfamily => 'RedHat',
    :selinux => true
  }}

  let(:params) {{
    :name => 'test.conf',
    :ensure => 'present',
    :content => 'Test',
    :owner => 'root',
    :group => 'apache',
    :mode => '0640',
  }}

  it do
    is_expected.to contain_file("/etc/httpd/conf.d/test.conf")
        .with({
          "ensure" => "present",
          "owner" => "root",
          "group" => "apache",
          "mode" => "0640",
          "seluser" => "system_u",
          "selrole" => "object_r",
          "seltype" => "httpd_config_t",
          "content" => "Test",
        })
        .that_requires('Package[httpd]')
        .that_notifies('Service[httpd]')
  end
end
