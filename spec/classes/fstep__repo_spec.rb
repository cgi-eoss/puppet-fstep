require 'spec_helper'

#Puppet::Util::Log.level = :debug
#Puppet::Util::Log.newdestination(:console)

describe 'fstep::repo', :type => 'class' do
  it { should compile }
  it { should contain_class('fstep::repo') }
  it { should contain_class('fstep::repo::yum') }
  it { should contain_yumrepo('fstep').with_baseurl('file:///path/to/repo') }
end
