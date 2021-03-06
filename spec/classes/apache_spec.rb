require 'spec_helper'
require 'shared_contexts'

describe 'apache' do
  context 'Unsupported OS' do
    let(:facts) {{
      :osfamily => 'FreeBSD',
      :operatingsystem => 'FreeBSD'
    }}

    it { should compile.and_raise_error(/not supported/) }
  end

  
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let (:facts) { facts }

      it { is_expected.to contain_file('/etc/httpd/conf/httpd.conf') }

      context 'SELinux enabled' do
        let(:facts) do
           facts.merge({ :selinux => true, })
        end

        it { is_expected.to contain_selboolean('httpd_anon_write').with({ 'value' => 'off', }) }
        it { is_expected.to contain_selboolean('httpd_can_network_connect').with({ 'value' => 'off', }) }
        it { is_expected.to contain_selboolean('httpd_can_network_connect_db').with({ 'value' => 'off', }) }
        it { is_expected.to contain_selboolean('httpd_use_nfs').with({ 'value' => 'off', }) }
        it { is_expected.to contain_selboolean('httpd_execmem').with({ 'value' => 'off', }) }
        it { is_expected.to contain_selboolean('httpd_can_sendmail').with({ 'value' => 'off', }) }
      end

      context 'SELinux disabled' do
        let(:facts) do
           facts.merge({ :selinux => false, })
        end

        it { is_expected.not_to contain_selboolean('httpd_anon_write') }
        it { is_expected.not_to contain_selboolean('httpd_can_network_connect') }
        it { is_expected.not_to contain_selboolean('httpd_can_network_connect_db') }
        it { is_expected.not_to contain_selboolean('httpd_use_nfs') }
        it { is_expected.not_to contain_selboolean('httpd_execmem') }
        it { is_expected.not_to contain_selboolean('httpd_can_sendmail') }
      end

      context "manage_firewall => true" do
        let(:params) {{ 'manage_firewall' => true }}

        it do
          is_expected.to contain_class('firewall')
        end

        it {
          is_expected.to contain_firewall('100 allow http')
              .with({
                'dport'  => 80,
                'proto'  => 'tcp',
                'action' => 'accept'
              })
        }
      end

      context "manage_firewall => false" do
        let(:params) {{ 'manage_firewall' => false }}

        it do
          is_expected.not_to contain_class('firewall')
        end

        it {
          is_expected.not_to contain_firewall('100 allow http')
        }
      end

       it do
        is_expected.to contain_package('httpd')
            .with({
              'ensure' => 'installed',
            })
            .that_notifies('Service[httpd]')
      end

      it do
        is_expected.to contain_service('httpd')
            .with({
              'ensure' => 'running',
              'enable' => true,
              'hasrestart' => true,
              'hasstatus' => true,
              })
      end
    end
  end
end
