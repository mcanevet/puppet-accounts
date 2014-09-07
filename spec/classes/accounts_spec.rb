require 'spec_helper'

describe 'accounts' do

  let(:facts) { {
    :osfamily => 'Debian',
  } }

  context 'with no parameters' do
    it { should compile.with_all_deps }
  end

  context 'whith groups only' do
    let(:params) do
      {
        :groups => {
          'foo' => {},
          'bar' => {},
          'baz' => { 'ensure' => 'absent' },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(3) }
    it { should contain_group('foo').with({ :ensure => nil }) }
    it { should contain_group('bar').with({ :ensure => nil }) }
    it { should contain_group('baz').with({ :ensure => :absent }) }

    it { should have_ssh_authorized_key_resource_count(0) }

    it { should have_user_resource_count(0) }
  end

  context 'with ssh_keys only' do
    let(:params) do
      {
        :ssh_keys => {
          'foo' => {
            'type'   => 'ssh-rsa',
            'public' => 'FOO-S-RSA-PUBLIC-KEY',
          },
          'bar' => {
            'type'   => 'ssh-rsa',
            'public' => 'BAR-S-RSA-PUBLIC-KEY',
          },
          'baz' => {
            'ensure'  => 'absent',
            'type'    => 'ssh-rsa',
	    'private' => 'BAR-S-RSA-PRIVATE-KEY',
            'public'  => 'BAR-S-RSA-PUBLIC-KEY',
          },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(0) }

    it { should have_ssh_authorized_key_resource_count(0) }

    it { should have_user_resource_count(0) }
  end

  context 'with users only' do
    let(:params) do
      {
        :users => {
          'foo' => {
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
          'bar' => {
            'comment' => 'Bar User',
            'uid'     => 1001,
          },
          'baz' => {
            'ensure'  => 'absent',
            'comment' => 'Baz User',
            'uid'     => 1002,
          },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(0) }

    it { should have_ssh_authorized_key_resource_count(0) }

    it { should have_user_resource_count(1) }
    it { should contain_user('baz').with({ :ensure => :absent })}
  end

  context 'when adding an account with no public key' do
    let(:params) do
      {
        :users       => {
          'foo' => {
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
        },
        :accounts    => {
          'foo' => { },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(0) }

    it { should have_ssh_authorized_key_resource_count(0) }

    it { should have_user_resource_count(1) }
    it { should contain_user('foo') }
  end

  context 'when adding an account with no user' do
    let(:params) do
      {
        :ssh_keys => {
          'foo' => {
            'type'   => 'ssh-rsa',
            'public' => 'FOO-S-RSA-PUBLIC-KEY',
          },
	},
        :accounts    => {
          'foo' => { },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(0) }

    it { should have_ssh_authorized_key_resource_count(1) }
    it { should contain_ssh_authorized_key('foo-on-foo').with({
      :type => 'ssh-rsa',
      :key  => 'FOO-S-RSA-PUBLIC-KEY',
    })}

    it { should have_user_resource_count(0) }
  end

  context 'when adding an account with a private key' do
    let(:params) do
      {
        :ssh_keys => {
          'foo' => {
            'type'    => 'ssh-rsa',
	    'private' => 'FOO-S-RSA-PRIVATE-KEY',
            'public'  => 'FOO-S-RSA-PUBLIC-KEY',
          },
        },
        :users       => {
          'foo' => {
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
        },
        :accounts    => {
          'foo' => { },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(0) }

    it { should have_ssh_authorized_key_resource_count(1) }
    it { should contain_ssh_authorized_key('foo-on-foo').with({
      :key  => 'FOO-S-RSA-PUBLIC-KEY',
      :type => 'ssh-rsa',
    }) }

    it { should have_user_resource_count(1) }
    it { should contain_user('foo') }

    it { should contain_exec("/bin/echo 'FOO-S-RSA-PRIVATE-KEY' > ~foo/.ssh/id_rsa").with({
      :unless => '/usr/bin/test -f ~foo/.ssh/id_rsa',
    })}
  end

  context 'when adding an account in a group not declared' do
    let(:params) do
      {
        :users       => {
          'foo' => {
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
        },
        :accounts    => {
          'foo' => {
            'groups' => [ 'foo', ],
          },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(0) }

    it { should have_ssh_authorized_key_resource_count(0) }

    it { should have_user_resource_count(1) }
    it { should contain_user('foo').with({ :groups => [ 'foo', ] }) }
  end

  context 'when adding an account in a group declared' do
    let(:params) do
      {
        :groups      => {
          'foo' => { },
        },
        :users       => {
          'foo' => {
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
        },
        :accounts    => {
          'foo' => {
            'groups' => [ 'foo', ],
          },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(1) }
    it { should contain_group('foo').with({ :ensure => nil }) }

    it { should have_ssh_authorized_key_resource_count(0) }

    it { should have_user_resource_count(1) }
    it { should contain_user('foo').with({ :groups => [ 'foo', ] }) }
  end

  context 'when adding an account in multiple groups' do
    let(:params) do
      {
        :groups      => {
          'foo' => { },
        },
        :users       => {
          'foo' => {
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
        },
        :accounts    => {
          'foo' => {
            'groups' => [ 'foo', 'bar', ],
          },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(1) }
    it { should contain_group('foo').with({ :ensure => nil }) }

    it { should have_ssh_authorized_key_resource_count(0) }

    it { should have_user_resource_count(1) }
    it { should contain_user('foo').with({ :groups => [ 'foo', 'bar', ] }) }
  end

  context 'when adding an account with only its ssh_key' do
    let(:params) do
      {
        :ssh_keys => {
          'foo' => {
            'type'   => 'ssh-rsa',
            'public'    => 'FOO-S-RSA-PUBLIC-KEY',
          },
        },
        :users       => {
          'foo' => {
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
        },
        :accounts    => {
          'foo' => { },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(0) }

    it { should have_ssh_authorized_key_resource_count(1) }
    it { should contain_ssh_authorized_key('foo-on-foo').with({ :user => 'foo' }) }

    it { should have_user_resource_count(1) }
    it { should contain_user('foo') }
  end

  context 'when authorized_keys is a string' do
    let(:params) do
      {
        :ssh_keys => {
          'foo' => {
            'type'   => 'ssh-rsa',
            'public' => 'FOO-S-RSA-PUBLIC-KEY',
          },
          'bar' => {
            'type'   => 'ssh-rsa',
            'public' => 'BAR-S-RSA-PUBLIC-KEY',
          },
        },
        :users       => {
          'foo' => {
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
        },
        :accounts    => {
          'foo' => {
            'authorized_keys' => 'bar',
	  },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(0) }

    it { should have_ssh_authorized_key_resource_count(2) }
    it { should contain_ssh_authorized_key('foo-on-foo').with({ :user => 'foo' }) }
    it { should contain_ssh_authorized_key('bar-on-foo').with({ :user => 'foo' }) }

    it { should have_user_resource_count(1) }
    it { should contain_user('foo') }
  end

  context 'when authorized_keys is an array' do
    let(:params) do
      {
        :ssh_keys => {
          'foo' => {
            'type'   => 'ssh-rsa',
            'public' => 'FOO-S-RSA-PUBLIC-KEY',
          },
          'bar' => {
            'type'   => 'ssh-rsa',
            'public' => 'BAR-S-RSA-PUBLIC-KEY',
          },
        },
        :users       => {
          'foo' => {
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
        },
        :accounts    => {
          'foo' => {
            'authorized_keys' => [ 'bar' ],
	  },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(0) }

    it { should have_ssh_authorized_key_resource_count(2) }
    it { should contain_ssh_authorized_key('foo-on-foo').with({ :user => 'foo' }) }
    it { should contain_ssh_authorized_key('bar-on-foo').with({ :user => 'foo' }) }

    it { should have_user_resource_count(1) }
    it { should contain_user('foo') }
  end

  context 'when authorized_keys is a hash' do
    let(:params) do
      {
        :ssh_keys => {
          'foo' => {
            'type'   => 'ssh-rsa',
            'public'    => 'FOO-S-RSA-PUBLIC-KEY',
          },
          'bar' => {
            'type'   => 'ssh-rsa',
            'public'    => 'BAR-S-RSA-PUBLIC-KEY',
          },
        },
        :users       => {
          'foo' => {
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
        },
        :accounts    => {
          'foo' => {
            'authorized_keys' => {
              'bar' => ['no-pty', 'no-port-forwarding', 'no-X11-forwarding'],
            },
	  },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(0) }

    it { should have_ssh_authorized_key_resource_count(2) }
    it { should contain_ssh_authorized_key('foo-on-foo').with({ :user => 'foo' }) }
    it { should contain_ssh_authorized_key('bar-on-foo').with({
      :user    => 'foo',
      :options => ['no-pty', 'no-port-forwarding', 'no-X11-forwarding'],
    }) }

    it { should have_user_resource_count(1) }
    it { should contain_user('foo') }
  end

  context 'when using an undefined user group' do
    let(:params) do
      {
        :accounts => {
          '@foo' => { },
	},
      }
    end

    it { expect { should compile.with_all_deps}.to raise_error(Puppet::Error, /Can't find usergroup : foo/) }

  end

  context 'when adding a user group' do
    let(:params) do
      {
        :ssh_keys => {
          'foo' => {
            'type'   => 'ssh-rsa',
            'public'    => 'FOO-S-RSA-PUBLIC-KEY',
          },
          'bar' => {
            'type'   => 'ssh-rsa',
            'public'    => 'BAR-S-RSA-PUBLIC-KEY',
          },
          'baz' => {
            'type'   => 'ssh-rsa',
            'public'    => 'BAZ-S-RSA-PUBLIC-KEY',
          },
          'qux' => {
            'type'   => 'ssh-rsa',
            'public'    => 'QUX-S-RSA-PUBLIC-KEY',
          },
        },
        :users       => {
          'foo' => {
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
          'bar' => {
            'comment' => 'Bar User',
            'uid'     => 1001,
          },
          'baz' => {
            'comment' => 'Baz User',
            'uid'     => 1002,
          },
          'qux' => {
            'comment' => 'Qux User',
            'uid'     => 1003,
          },
        },
        :usergroups  => {
          'foo' => [ 'foo', 'baz', ],
          'bar' => [ 'bar', 'qux', ],
        },
        :accounts    => {
          '@foo' => {
            'groups' => [ 'foo', ],
          },
          '@bar' => {
            'groups' => [ 'bar', ],
          },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(0) }

    it { should have_ssh_authorized_key_resource_count(4) }
    it { should contain_ssh_authorized_key('foo-on-foo').with({ :ensure => :present }) }
    it { should contain_ssh_authorized_key('bar-on-bar').with({ :ensure => :present }) }
    it { should contain_ssh_authorized_key('baz-on-baz').with({ :ensure => :present }) }
    it { should contain_ssh_authorized_key('qux-on-qux').with({ :ensure => :present }) }

    it { should have_user_resource_count(4) }
    it { should contain_user('foo').with({ :ensure => :present, :groups => 'foo', }) }
    it { should contain_user('bar').with({ :ensure => :present, :groups => 'bar', }) }
    it { should contain_user('baz').with({ :ensure => :present, :groups => 'foo', }) }
    it { should contain_user('qux').with({ :ensure => :present, :groups => 'bar', }) }
  end

  context 'when adding a user group with ambiguous groups' do
    let(:params) do
      {
        :ssh_keys => {
          'foo' => {
            'type'   => 'ssh-rsa',
            'public'    => 'FOO-S-RSA-PUBLIC-KEY',
          },
          'bar' => {
            'type'   => 'ssh-rsa',
            'public'    => 'BAR-S-RSA-PUBLIC-KEY',
          },
          'baz' => {
            'type'   => 'ssh-rsa',
            'public'    => 'BAZ-S-RSA-PUBLIC-KEY',
          },
          'qux' => {
            'type'   => 'ssh-rsa',
            'public'    => 'QUX-S-RSA-PUBLIC-KEY',
          },
        },
        :users       => {
          'foo' => {
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
          'bar' => {
            'comment' => 'Bar User',
            'uid'     => 1001,
          },
          'baz' => {
            'comment' => 'Baz User',
            'uid'     => 1002,
          },
          'qux' => {
            'comment' => 'Qux User',
            'uid'     => 1003,
          },
        },
        :usergroups  => {
          'foo' => [ 'foo', 'bar', 'baz', ],
          'bar' => [ 'bar', 'qux', ],
        },
        :accounts    => {
          '@foo' => {
            'groups' => [ 'foo', ],
          },
          '@bar' => {
            'groups' => [ 'bar', ],
          },
        },
      }
    end

    it {
      pending
      should compile.with_all_deps
    }
    it {
      pending
      should have_group_resource_count(0)
    }
    it {
      pending
      should have_ssh_authorized_key_resource_count(4)
    }
    it {
      pending
      should contain_ssh_authorized_key('foo-on-foo').with({ :ensure => :present })
    }
    it {
      pending
      should contain_ssh_authorized_key('bar-on-bar').with({ :ensure => :present })
    }
    it {
      pending
      should contain_ssh_authorized_key('baz-on-baz').with({ :ensure => :present })
    }
    it {
      pending
      should contain_ssh_authorized_key('qux-on-qux').with({ :ensure => :present })
    }
    it {
      pending
      should have_user_resource_count(4)
    }
    it {
      pending
      should contain_user('foo').with({ :ensure => nil, :groups => 'foo', })
    }
    it {
      pending
      should contain_user('bar').with({ :ensure => nil, :groups => 'bar', })
    }
    it {
      pending
      should contain_user('baz').with({ :ensure => nil, :groups => 'foo', })
    }
    it {
      pending
      should contain_user('qux').with({ :ensure => nil, :groups => 'bar', })
    }
  end

  context 'when adding a public keys of a user group' do
    let(:params) do
      {
        :ssh_keys => {
          'foo' => {
            'type'   => 'ssh-rsa',
            'public'    => 'FOO-S-RSA-PUBLIC-KEY',
          },
          'bar' => {
            'type'   => 'ssh-rsa',
            'public'    => 'BAR-S-RSA-PUBLIC-KEY',
          },
          'baz' => {
            'type'   => 'ssh-rsa',
            'public'    => 'BAZ-S-RSA-PUBLIC-KEY',
          },
          'qux' => {
            'type'   => 'ssh-rsa',
            'public'    => 'QUX-S-RSA-PUBLIC-KEY',
          },
        },
        :users       => {
          'foo' => {
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
          'bar' => {
            'comment' => 'Bar User',
            'uid'     => 1001,
          },
          'baz' => {
            'comment' => 'Baz User',
            'uid'     => 1002,
          },
          'qux' => {
            'comment' => 'Qux User',
            'uid'     => 1003,
          },
        },
        :usergroups  => {
          'foo' => [ 'foo', 'baz', ],
          'bar' => [ 'bar', 'qux', ],
        },
        :accounts    => {
          'quux' => {
            'authorized_keys' => [ '@foo', ],
          },
          'corge' => {
            'authorized_keys' => {
              '@bar' => ['no-pty', 'no-port-forwarding', 'no-X11-forwarding'],
            },
          },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(0) }

    it { should have_ssh_authorized_key_resource_count(4) }
    it { should contain_ssh_authorized_key('foo-on-quux').with({ :ensure => :present }) }
    it { should contain_ssh_authorized_key('bar-on-corge').with({
      :ensure  => :present,
      :options => ['no-pty', 'no-port-forwarding', 'no-X11-forwarding'],
    }) }
    it { should contain_ssh_authorized_key('baz-on-quux').with({ :ensure => :present }) }
    it { should contain_ssh_authorized_key('qux-on-corge').with({
      :ensure  => :present,
      :options => ['no-pty', 'no-port-forwarding', 'no-X11-forwarding'],
    }) }

    it { should have_user_resource_count(0) }
  end

  context 'when removing an account' do
    let(:params) do
      {
        :ssh_keys => {
          'foo' => {
            'type'   => 'ssh-rsa',
            'public' => 'FOO-S-RSA-PUBLIC-KEY',
          },
          'bar' => {
            'type'   => 'ssh-rsa',
            'public' => 'BAR-S-RSA-PUBLIC-KEY',
          },
        },
        :users       => {
          'foo' => {
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
        },
        :accounts    => {
          'foo' => {
            'ensure' => 'absent',
          },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(0) }

    it { should have_ssh_authorized_key_resource_count(0) }

    it { should have_user_resource_count(1) }
    it { should contain_user('foo').with({ :ensure => :absent }) }
  end

  context 'when removing an user' do
    let(:params) do
      {
        :ssh_keys => {
          'foo' => {
            'type'   => 'ssh-rsa',
            'public'    => 'FOO-S-RSA-PUBLIC-KEY',
          },
          'bar' => {
            'type'   => 'ssh-rsa',
            'public'    => 'BAR-S-RSA-PUBLIC-KEY',
          },
        },
        :users       => {
          'foo' => {
            'ensure' => 'absent',
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(0) }

    it { should have_ssh_authorized_key_resource_count(0) }

    it { should have_user_resource_count(1) }
    it { should contain_user('foo').with({ :ensure => :absent }) }
  end

  context 'when removing a public key' do
    let(:params) do
      {
        :ssh_keys => {
          'foo' => {
            'type'   => 'ssh-rsa',
            'public'    => 'FOO-S-RSA-PUBLIC-KEY',
          },
          'bar' => {
            'ensure' => 'absent',
            'type'   => 'ssh-rsa',
            'public'    => 'BAR-S-RSA-PUBLIC-KEY',
          },
        },
        :users       => {
          'foo' => {
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
        },
        :accounts    => {
          'foo' => { },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(0) }

    it { should have_ssh_authorized_key_resource_count(2) }
    it { should contain_ssh_authorized_key('foo-on-foo').with({ :ensure => :present }) }
    it { should contain_ssh_authorized_key('bar-on-foo').with({ :ensure => :absent }) }

    it { should have_user_resource_count(1) }
    it { should contain_user('foo') }
  end

  context 'when complex scenario' do
    let(:params) do
      {
        :ssh_keys => {
          'foo' => {
            'type'   => 'ssh-rsa',
            'public'    => 'FOO-S-RSA-PUBLIC-KEY',
          },
          'bar' => {
            'ensure' => 'absent', # We want to remove the public key but not the user
            'type'   => 'ssh-rsa',
            'public'    => 'BAR-S-RSA-PUBLIC-KEY',
          },
          'qux' => {
            'type'   => 'ssh-rsa',
            'public'    => 'QUX-S-RSA-PUBLIC-KEY',
          },
          'quux' => {
            'type'   => 'ssh-rsa',
            'public'    => 'QUUX-S-RSA-PUBLIC-KEY',
          },
          'corge' => { # is just a public key, without user associated
            'type'   => 'ssh-rsa',
            'public'    => 'CORGE-S-RSA-PUBLIC-KEY',
          },
        },
        :users       => {
          'foo' => {
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
          'bar' => {
            'comment' => 'Bar User',
            'uid'     => 1001,
          },
          'baz' => {
            'comment' => 'Baz User',
            'uid'     => 1002,
          },
          'qux' => {
            'comment' => 'Qux User',
            'uid'     => 1003,
          },
          'quux' => {
            'ensure'  => 'absent', # Do we want to remove its public key also ?
            'comment' => 'Quux User',
            'uid'     => 1004,
          }
        },
        :accounts    => {
          'foo' => { # An account with multiple public keys
            'authorized_keys' => [ 'qux', 'quux', 'corge', ],
          },
	  'baz' => { # An account without public key
          },
          'qux' => { # A removed account
            'ensure' => 'absent',
          },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(0) }

    it { should have_ssh_authorized_key_resource_count(7) }
    it { should contain_ssh_authorized_key('foo-on-foo').with({ :ensure => :present }) }
    it { should contain_ssh_authorized_key('bar-on-foo').with({ :ensure => :absent }) }
    it { should contain_ssh_authorized_key('qux-on-foo').with({ :ensure => :present }) }
    it { should contain_ssh_authorized_key('quux-on-foo').with({ :ensure => :present }) }
    it { should contain_ssh_authorized_key('corge-on-foo').with({ :ensure => :present }) }
    it { should contain_ssh_authorized_key('bar-on-baz').with({ :ensure => :absent }) }
    it { should contain_ssh_authorized_key('bar-on-qux').with({ :ensure => :absent }) }

    it { should have_user_resource_count(4) }
    it { should contain_user('foo').with({ :ensure => :present }) }
    it { should contain_user('baz').with({ :ensure => :present }) }
    it { should contain_user('qux').with({ :ensure => :absent }) }
  end

end
