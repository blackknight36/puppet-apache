require 'spec_helper'
require 'shared_contexts'

describe 'apache::mod_passenger' do
  let(:facts) {{
    :operatingsystem => 'CentOS',
    :osfamily => 'RedHat',
    :selinux => true
  }}

  let(:params) {{
    :packages => ['mod_passenger'],
  }}

  it do
    is_expected.to contain_package('mod_passenger')
        .with({
          "ensure" => "installed",
        })
        .that_notifies('Service[httpd]')
  end
end
