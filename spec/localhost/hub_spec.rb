require 'spec_helper'

describe package('selenium') do
  it { should be_installed }
end

describe service('SeleniumHub') do
  it { should be_enabled }
  it { should be_running }
end

describe port(4446) do
  it { should be_listening }
end
