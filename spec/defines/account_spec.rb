require 'spec_helper'

describe 'accounts::account 'do
  let(:title) { 'foo' }

  let(:facts) { { :osfamily => 'Debian' } }

  context 'when class ::accounts has not been evaluated' do
    it do
      expect{
        should compile.with_all_deps
      }.to raise_error(Puppet::Error, /class ::accounts has not been evaluated/)
    end
  end

  context 'when class ::accounts has been evaluated without params' do
    let(:pre_condition) { "class { 'accounts': }" }

    context 'without params' do
      it { should compile.with_all_deps }
    end

    context 'with authorized_keys => foo' do
      let(:params) { { :authorized_keys => 'foo' } }
      it do
        expect{
          should compile.with_all_deps
        }.to raise_error(Puppet::Error, /Can't find foo public_key in ::accounts::ssh_keys/)
      end
    end
  end

  context 'when class ::accounts has been evaluated with params' do
    let(:pre_condition) do
"class { 'accounts':
  ssh_keys => {
    bastion => {
      comment => 'bastion@example.com',
      public  => 'Bastion_public_key',
      type    => 'ssh-rsa',
    },
    luke  => {
      comment => 'luke@example.com',
      public  => 'Luke\\'s_public_key',
      type    => 'ssh-rsa',
    },
    nigel => {
      comment => 'nigel@example.com',
      public  => 'Nigel\\'s_public_key',
      type    => 'ssh-dss',
    },
    bill  => {
      comment => 'bill@example.com',
      public  => 'Bill\\'s_public_key',
      type    => 'ssh-rsa',
    },
    puneet  => {
      public => 'Puneet\\'s_public_key',
      type   => 'ssh-rsa',
    },
    kevin  => {
      public => 'Kevin\\'s_public_key',
      type   => 'ssh-rsa',
    },
    raghu  => {
      public => 'Raghu\\'s_public_key',
      type   => 'ssh-rsa',
    },
    kenny  => {
      public => 'Kenny\\'s_public_key',
      type   => 'ssh-rsa',
    },
    traitor => {
      ensure  => 'absent',
      comment => 'traitor@example.com',
      public  => 'Traitor\\'s_public_key',
      type    => 'ssh-rsa',
    }
  },
  users    => {
    luke => {
      comment => 'Luke',
      uid     => 1000,
    },
    nigel => {
      uid => 1001,
    },
    bill => {
      uid => 1002,
    },
    puneet => {
      uid => 1003,
    },
    kevin => {
      uid => 1004,
    },
    raghu => {
      uid => 1005,
    },
    kenny => {
      uid => 1006,
    },
    karim => {
      uid => 1007,
    },
    phil => {
      uid => 1008,
    },
    matt => {
      uid => 1009,
    },
    beth => {
      uid => 1010,
    },
    sharmila => {
      uid => 1011,
    },
    traitor => {
      ensure  => absent,
      comment => 'Traitor',
      uid     => 1012,
    },
  },
  usergroups => {
    management => [ 'luke', 'nigel', 'bill', ],
    directors  => [ 'puneet', 'kevin', 'luke', 'raghu', 'kenny', ],
    observers  => [ 'karim', 'phil', 'matt', ],
    advisors   => [ 'beth', 'sharmila', ],
  },
}"
    end

    context 'without params' do
      it { should compile.with_all_deps }
      it { should have_ssh_authorized_key_resource_count(1) }
      it do
        should contain_ssh_authorized_key('traitor-on-foo').only_with({
          :name   => 'traitor-on-foo',
          :ensure => :absent,
          :key    => "Traitor's_public_key",
          :type   => 'ssh-rsa',
          :user   => 'foo',
        })
      end
    end

    context 'when authorized_keys is a string' do
      let(:params) { { :authorized_keys => 'luke' } }
      it { should compile.with_all_deps }
      it { should have_ssh_authorized_key_resource_count(2) }
      it do
        should contain_ssh_authorized_key('luke-on-foo').only_with({
          :name    => 'luke-on-foo',
          :ensure  => :present,
          :key     => "Luke's_public_key",
          :type    => 'ssh-rsa',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('traitor-on-foo').only_with({
          :name   => 'traitor-on-foo',
          :ensure => :absent,
          :key    => "Traitor's_public_key",
          :type   => 'ssh-rsa',
          :user   => 'foo',
        })
      end
    end

    context 'when authorized_keys is an array' do
      let(:params) { { :authorized_keys => ['luke', 'nigel'] } }
      it { should compile.with_all_deps }
      it { should have_ssh_authorized_key_resource_count(3) }
      it do
        should contain_ssh_authorized_key('luke-on-foo').only_with({
          :name    => 'luke-on-foo',
          :ensure  => :present,
          :key     => "Luke's_public_key",
          :type    => 'ssh-rsa',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('nigel-on-foo').only_with({
          :name    => 'nigel-on-foo',
          :ensure  => :present,
          :key     => "Nigel's_public_key",
          :type    => 'ssh-dss',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('traitor-on-foo').only_with({
          :name   => 'traitor-on-foo',
          :ensure => :absent,
          :key    => "Traitor's_public_key",
          :type   => 'ssh-rsa',
          :user   => 'foo',
        })
      end
    end

    context 'when authorized_keys is a usergroup' do
      let(:params) { { :authorized_keys => '@management' } }
      it { should compile.with_all_deps }
      it { should have_ssh_authorized_key_resource_count(4) }
      it do
        should contain_ssh_authorized_key('luke-on-foo').only_with({
          :name    => 'luke-on-foo',
          :ensure  => :present,
          :key     => "Luke's_public_key",
          :type    => 'ssh-rsa',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('nigel-on-foo').only_with({
          :name    => 'nigel-on-foo',
          :ensure  => :present,
          :key     => "Nigel's_public_key",
          :type    => 'ssh-dss',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('bill-on-foo').only_with({
          :name    => 'bill-on-foo',
          :ensure  => :present,
          :key     => "Bill's_public_key",
          :type    => 'ssh-rsa',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('traitor-on-foo').only_with({
          :name   => 'traitor-on-foo',
          :ensure => :absent,
          :key    => "Traitor's_public_key",
          :type   => 'ssh-rsa',
          :user   => 'foo',
        })
      end
    end

    context 'when authorized_keys is an array with user and usergroup' do
      let(:params) { { :authorized_keys => ['bastion', '@management'] } }
      it { should compile.with_all_deps }
      it { should have_ssh_authorized_key_resource_count(5) }
      it do
        should contain_ssh_authorized_key('bastion-on-foo').only_with({
          :name    => 'bastion-on-foo',
          :ensure  => :present,
          :key     => "Bastion_public_key",
          :type    => 'ssh-rsa',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('luke-on-foo').only_with({
          :name    => 'luke-on-foo',
          :ensure  => :present,
          :key     => "Luke's_public_key",
          :type    => 'ssh-rsa',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('nigel-on-foo').only_with({
          :name    => 'nigel-on-foo',
          :ensure  => :present,
          :key     => "Nigel's_public_key",
          :type    => 'ssh-dss',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('bill-on-foo').only_with({
          :name    => 'bill-on-foo',
          :ensure  => :present,
          :key     => "Bill's_public_key",
          :type    => 'ssh-rsa',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('traitor-on-foo').only_with({
          :name   => 'traitor-on-foo',
          :ensure => :absent,
          :key    => "Traitor's_public_key",
          :type   => 'ssh-rsa',
          :user   => 'foo',
        })
      end
    end

    context 'when authorized_keys is an array of usergroups' do
      let(:params) { { :authorized_keys => ['@management', '@directors'] } }
      it { should compile.with_all_deps }
      it { should have_ssh_authorized_key_resource_count(8) }
      it do
        should contain_ssh_authorized_key('luke-on-foo').only_with({
          :name    => 'luke-on-foo',
          :ensure  => :present,
          :key     => "Luke's_public_key",
          :type    => 'ssh-rsa',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('nigel-on-foo').only_with({
          :name    => 'nigel-on-foo',
          :ensure  => :present,
          :key     => "Nigel's_public_key",
          :type    => 'ssh-dss',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('bill-on-foo').only_with({
          :name    => 'bill-on-foo',
          :ensure  => :present,
          :key     => "Bill's_public_key",
          :type    => 'ssh-rsa',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('puneet-on-foo').only_with({
          :name    => 'puneet-on-foo',
          :ensure  => :present,
          :key     => "Puneet's_public_key",
          :type    => 'ssh-rsa',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('kevin-on-foo').only_with({
          :name    => 'kevin-on-foo',
          :ensure  => :present,
          :key     => "Kevin's_public_key",
          :type    => 'ssh-rsa',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('raghu-on-foo').only_with({
          :name    => 'raghu-on-foo',
          :ensure  => :present,
          :key     => "Raghu's_public_key",
          :type    => 'ssh-rsa',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('kenny-on-foo').only_with({
          :name    => 'kenny-on-foo',
          :ensure  => :present,
          :key     => "Kenny's_public_key",
          :type    => 'ssh-rsa',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('traitor-on-foo').only_with({
          :name   => 'traitor-on-foo',
          :ensure => :absent,
          :key    => "Traitor's_public_key",
          :type   => 'ssh-rsa',
          :user   => 'foo',
        })
      end
    end

    context 'when target_format is specified' do
      let(:params) do {
        :authorized_keys => 'bastion',
        :target_format   => '/etc/ssh/authorized_keys/%{name}',
      } end
      it { should compile.with_all_deps }
      it { should have_ssh_authorized_key_resource_count(2) }
      it do
        should contain_ssh_authorized_key('bastion-on-foo').only_with({
          :name    => 'bastion-on-foo',
          :ensure  => :present,
          :key     => "Bastion_public_key",
          :target  => '/etc/ssh/authorized_keys/foo',
          :type    => 'ssh-rsa',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('traitor-on-foo').only_with({
          :name   => 'traitor-on-foo',
          :ensure => :absent,
          :key    => "Traitor's_public_key",
          :target  => '/etc/ssh/authorized_keys/foo',
          :type   => 'ssh-rsa',
          :user   => 'foo',
        })
      end
    end

    context 'when key_comment_format is looked up from $ssh_keys hash' do
      let(:params) do {
        :authorized_keys    => 'bastion',
        :key_comment_format => "%{ssh_keys['%{ssh_key}']['comment']}"
      } end
      it { should compile.with_all_deps }
      it { should have_ssh_authorized_key_resource_count(2) }
      it do
        should contain_ssh_authorized_key('bastion-on-foo').only_with({
          :name    => 'bastion@example.com',
          :ensure  => :present,
          :key     => "Bastion_public_key",
          :type    => 'ssh-rsa',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('traitor-on-foo').only_with({
          :name   => 'traitor@example.com',
          :ensure => :absent,
          :key    => "Traitor's_public_key",
          :type   => 'ssh-rsa',
          :user   => 'foo',
        })
      end
    end

    context 'when key_comment_format is looked up from $user hash' do
      let(:params) do {
        :authorized_keys    => 'luke',
        :key_comment_format => "%{users['%{ssh_key}']['comment']}"
      } end
      it { should compile.with_all_deps }
      it { should have_ssh_authorized_key_resource_count(2) }
      it do
        should contain_ssh_authorized_key('luke-on-foo').only_with({
          :name    => 'Luke',
          :ensure  => :present,
          :key     => "Luke\'s_public_key",
          :type    => 'ssh-rsa',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('traitor-on-foo').only_with({
          :name   => 'Traitor',
          :ensure => :absent,
          :key    => "Traitor's_public_key",
          :type   => 'ssh-rsa',
          :user   => 'foo',
        })
      end
    end

    context 'when authorized_keys is a hash and key_comment_format is looked up from ssh_keys hash' do
      let(:params) do {
        :authorized_keys    => ['luke', 'nigel'],
        :key_comment_format => "%{ssh_keys['%{ssh_key}']['comment']}",
      } end
      it { should compile.with_all_deps }
      it { should have_ssh_authorized_key_resource_count(3) }
      it do
        should contain_ssh_authorized_key('luke-on-foo').only_with({
          :name    => 'luke@example.com',
          :ensure  => :present,
          :key     => "Luke's_public_key",
          :type    => 'ssh-rsa',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('nigel-on-foo').only_with({
          :name    => 'nigel@example.com',
          :ensure  => :present,
          :key     => "Nigel's_public_key",
          :type    => 'ssh-dss',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('traitor-on-foo').only_with({
          :name   => 'traitor@example.com',
          :ensure => :absent,
          :key    => "Traitor's_public_key",
          :type   => 'ssh-rsa',
          :user   => 'foo',
        })
      end
    end

    context 'when authorized_keys is a usergroup and key_comment_format is looked up from ssh_keys hash' do
      let(:params) do {
        :authorized_keys    => '@management',
        :key_comment_format => "%{ssh_keys['%{ssh_key}']['comment']}",
      } end
      it { should compile.with_all_deps }
      it { should have_ssh_authorized_key_resource_count(4) }
      it do
        should contain_ssh_authorized_key('luke-on-foo').only_with({
          :name    => 'luke@example.com',
          :ensure  => :present,
          :key     => "Luke's_public_key",
          :type    => 'ssh-rsa',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('nigel-on-foo').only_with({
          :name    => 'nigel@example.com',
          :ensure  => :present,
          :key     => "Nigel's_public_key",
          :type    => 'ssh-dss',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('bill-on-foo').only_with({
          :name    => 'bill@example.com',
          :ensure  => :present,
          :key     => "Bill's_public_key",
          :type    => 'ssh-rsa',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('traitor-on-foo').only_with({
          :name   => 'traitor@example.com',
          :ensure => :absent,
          :key    => "Traitor's_public_key",
          :type   => 'ssh-rsa',
          :user   => 'foo',
        })
      end
    end

    context 'when authorized_keys is a hash' do
      let(:params) do
        {
          :authorized_keys => {
            'luke'  => 'from="192.168.0.0/24"',
            'nigel' => 'from="10.0.0.0/8"',
          }
        }
      end
      it { should compile.with_all_deps }
      it { should have_ssh_authorized_key_resource_count(3) }
      it do
        should contain_ssh_authorized_key('luke-on-foo').only_with({
          :name    => 'luke-on-foo',
          :ensure  => :present,
          :key     => "Luke's_public_key",
          :options => 'from="192.168.0.0/24"',
          :type    => 'ssh-rsa',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('nigel-on-foo').only_with({
          :name    => 'nigel-on-foo',
          :ensure  => :present,
          :key     => "Nigel's_public_key",
          :options => 'from="10.0.0.0/8"',
          :type    => 'ssh-dss',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('traitor-on-foo').only_with({
          :name   => 'traitor-on-foo',
          :ensure => :absent,
          :key    => "Traitor's_public_key",
          :type   => 'ssh-rsa',
          :user   => 'foo',
        })
      end
    end

    context 'when authorized_keys is a usergroup and using a hash' do
      let(:params) do
        {
          :authorized_keys => {
            '@management' => 'from="10.0.0.0/8"',
          }
        }
      end
      it { should compile.with_all_deps }
      it { should have_ssh_authorized_key_resource_count(4) }
      it do
        should contain_ssh_authorized_key('luke-on-foo').only_with({
          :name    => 'luke-on-foo',
          :ensure  => :present,
          :key     => "Luke's_public_key",
          :options => 'from="10.0.0.0/8"',
          :type    => 'ssh-rsa',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('nigel-on-foo').only_with({
          :name    => 'nigel-on-foo',
          :ensure  => :present,
          :key     => "Nigel's_public_key",
          :options => 'from="10.0.0.0/8"',
          :type    => 'ssh-dss',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('bill-on-foo').only_with({
          :name    => 'bill-on-foo',
          :ensure  => :present,
          :key     => "Bill's_public_key",
          :options => 'from="10.0.0.0/8"',
          :type    => 'ssh-rsa',
          :user    => 'foo',
        })
      end
      it do
        should contain_ssh_authorized_key('traitor-on-foo').only_with({
          :name   => 'traitor-on-foo',
          :ensure => :absent,
          :key    => "Traitor's_public_key",
          :type   => 'ssh-rsa',
          :user   => 'foo',
        })
      end
    end

    context 'when title is an unknown usergroup' do
      let(:title) { '@foo' }
      it do
      expect{
        should compile.with_all_deps
      }.to raise_error(Puppet::Error, /Can't find usergroup : foo/)
      end
    end

    context 'when title is a usergroup and no params' do
      let(:title) { '@management' }
      it { should compile.with_all_deps }
      it { should have_ssh_authorized_key_resource_count(6) }
      it do
        should contain_ssh_authorized_key('luke-on-luke').only_with({
          :name   => 'luke-on-luke',
          :ensure => :present,
          :key    => "Luke's_public_key",
          :type   => 'ssh-rsa',
          :user   => 'luke',
        })
      end
      it do
        should contain_ssh_authorized_key('traitor-on-luke').only_with({
          :name   => 'traitor-on-luke',
          :ensure => :absent,
          :key    => "Traitor's_public_key",
          :type   => 'ssh-rsa',
          :user   => 'luke',
        })
      end
      it do
        should contain_ssh_authorized_key('nigel-on-nigel').only_with({
          :name   => 'nigel-on-nigel',
          :ensure => :present,
          :key    => "Nigel's_public_key",
          :type   => 'ssh-dss',
          :user   => 'nigel',
        })
      end
      it do
        should contain_ssh_authorized_key('traitor-on-nigel').only_with({
          :name   => 'traitor-on-nigel',
          :ensure => :absent,
          :key    => "Traitor's_public_key",
          :type   => 'ssh-rsa',
          :user   => 'nigel',
        })
      end
      it do
        should contain_ssh_authorized_key('bill-on-bill').only_with({
          :name   => 'bill-on-bill',
          :ensure => :present,
          :key    => "Bill's_public_key",
          :type   => 'ssh-rsa',
          :user   => 'bill',
        })
      end
      it do
        should contain_ssh_authorized_key('traitor-on-bill').only_with({
          :name   => 'traitor-on-bill',
          :ensure => :absent,
          :key    => "Traitor's_public_key",
          :type   => 'ssh-rsa',
          :user   => 'bill',
        })
      end
    end

    context 'when title is a usergroup and params' do
      let(:title) { '@management' }
      let(:params) { { :authorized_keys => 'luke' } }
      it { should compile.with_all_deps }
      it { should have_ssh_authorized_key_resource_count(8) }
      it do
        should contain_ssh_authorized_key('luke-on-luke').only_with({
          :name   => 'luke-on-luke',
          :ensure => :present,
          :key    => "Luke's_public_key",
          :type   => 'ssh-rsa',
          :user   => 'luke',
        })
      end
      it do
        should contain_ssh_authorized_key('traitor-on-luke').only_with({
          :name   => 'traitor-on-luke',
          :ensure => :absent,
          :key    => "Traitor's_public_key",
          :type   => 'ssh-rsa',
          :user   => 'luke',
        })
      end
      it do
        should contain_ssh_authorized_key('nigel-on-nigel').only_with({
          :name   => 'nigel-on-nigel',
          :ensure => :present,
          :key    => "Nigel's_public_key",
          :type   => 'ssh-dss',
          :user   => 'nigel',
        })
      end
      it do
        should contain_ssh_authorized_key('luke-on-nigel').only_with({
          :name   => 'luke-on-nigel',
          :ensure => :present,
          :key    => "Luke's_public_key",
          :type   => 'ssh-rsa',
          :user   => 'nigel',
        })
      end
      it do
        should contain_ssh_authorized_key('traitor-on-nigel').only_with({
          :name   => 'traitor-on-nigel',
          :ensure => :absent,
          :key    => "Traitor's_public_key",
          :type   => 'ssh-rsa',
          :user   => 'nigel',
        })
      end
      it do
        should contain_ssh_authorized_key('bill-on-bill').only_with({
          :name   => 'bill-on-bill',
          :ensure => :present,
          :key    => "Bill's_public_key",
          :type   => 'ssh-rsa',
          :user   => 'bill',
        })
      end
      it do
        should contain_ssh_authorized_key('luke-on-bill').only_with({
          :name   => 'luke-on-bill',
          :ensure => :present,
          :key    => "Luke's_public_key",
          :type   => 'ssh-rsa',
          :user   => 'bill',
        })
      end
      it do
        should contain_ssh_authorized_key('traitor-on-bill').only_with({
          :name   => 'traitor-on-bill',
          :ensure => :absent,
          :key    => "Traitor's_public_key",
          :type   => 'ssh-rsa',
          :user   => 'bill',
        })
      end
    end

  end

end
