require 'spec_helper'
require 'shared_contexts'

describe 'apache::mod_status' do
  let(:pre_condition) {
    include 'apache'
  }

  let(:facts) do
    { 'operatingsystem' => 'CentOS', 'osfamily' => 'RedHat', 'selinux' => true }
  end

  it do
    is_expected.to contain_file("/etc/httpd/conf.d/mod_status.conf")
      .with({
        "source" => "puppet:///modules/apache/mod_status.conf",
      })
      .that_notifies('Service[httpd]')
      .that_requires('Package[httpd]')
  end

end
