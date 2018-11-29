require 'hiera'
require 'spec_helper'
require 'shared_contexts'

describe 'apache::ssl_site_config' do
  let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }
  hiera = Hiera.new(:config => 'spec/fixtures/hiera/hiera.yaml')

  let(:title) { 'Apache::ssl_site_config::test' }

  let(:node) { 'host.example.com' }

  let(:facts) {{
    :operatingsystem => 'CentOS',
    :osfamily => 'RedHat',
    :selinux => true,
  }}

  let(:params) {{
    :ensure => 'present',
    :name => 'www.example.com',
    :conf_template => 'apache/ssl/ssl.conf.erb',
    :public_key => hiera.lookup("apache.ssl_site_config.'www.example.com'.public_key", nil, nil),
    :private_key => hiera.lookup("apache.ssl_site_config.'www.example.com'.private_key", nil, nil)
  }}

  let(:name) { 'www.example.com' }

  it do
    is_expected.to contain_file("/etc/pki/tls/certs/#{name}.crt")
        .with({
          "ensure" => "file",
          "show_diff" => false,
          "owner" => "root",
          "group" => "apache",
          "mode" => "0440",
          "seltype" => "cert_t",
          "selrole" => "object_r",
          "seluser" => "system_u",
          "content" => /-----BEGIN CERTIFICATE-----/
        })
  end

  it do
    is_expected.to contain_file("/etc/pki/tls/private/#{name}.key")
        .with({
          "ensure" => "file",
          "show_diff" => false,
          "owner" => "root",
          "group" => "apache",
          "mode" => "0440",
          "seltype" => "cert_t",
          "selrole" => "object_r",
          "seluser" => "system_u",
          "content" => /-----BEGIN RSA PRIVATE KEY-----/
        })
  end

  context "self_signed_certificate => false" do
    let(:params) {{
      :name => 'www.example.com',
      :content => 'SSLCACertificateFile /etc/pki/tls/certs/ca-bundle.crt',
      :self_signed_certificate => false,
    }}

    it do
      is_expected.to contain_file("/etc/httpd/conf.d/01-#{name}.ssl.conf")
          .with({
            :content => /^SSLCACertificateFile \/etc\/pki\/tls\/certs\/ca-bundle.crt/,
          })
    end
  end

  context "self_signed_certificate => true" do
    let(:params) {{
      :name => 'www.example.com',
      :content => '<VirtualHost *:443></VirtualHost>',
      :self_signed_certificate => true,
    }}

    it do
      is_expected.to contain_file("/etc/httpd/conf.d/01-#{name}.ssl.conf")
    end
  end

end
