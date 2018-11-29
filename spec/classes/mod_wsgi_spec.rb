require 'spec_helper'
require 'shared_contexts'

describe 'apache::mod_wsgi' do
  let(:pre_condition) {
    include 'apache'
  }

  let(:facts) do
    { 'operatingsystem' => 'CentOS', 'osfamily' => 'RedHat', 'selinux' => true }
  end

  let(:params) {{
    :packages => ['mod_wsgi'],
  }}

  it do
    is_expected.to contain_package('mod_wsgi')
        .with({
          "ensure" => "installed",
        })
        .that_notifies('Service[httpd]')
  end

end
