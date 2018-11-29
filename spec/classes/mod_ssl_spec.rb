require 'spec_helper'
require 'shared_contexts'

describe 'apache::mod_ssl' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let (:facts) { facts }

      it do
        is_expected.to contain_package('mod_ssl')
            .with({
              "ensure" => "installed",
            })
            .that_notifies('Service[httpd]')
      end

      context "manage_firewall => true" do
        let(:params) {{
          :manage_firewall => true,
        }}

        it {
          is_expected.to contain_firewall('101 allow https')
              .with({
                'dport' => 443,
                'proto' => 'tcp',
                'action' => 'accept'
              })
        }
      end

    end
  end
end
