require 'spec_helper'
require 'shared_contexts'

describe 'apache::mod_ldap' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let (:facts) { facts }

      it do
        is_expected.to contain_package('mod_ldap')
            .with({
              "ensure" => "installed",
            })
            .that_notifies('Service[httpd]')
      end

    end
  end
end
