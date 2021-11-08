require 'spec_helper'

describe file('C:/tools/selenium') do
  it { should be_directory }
end

describe file("C:/tools/selenium/selenium-server.jar") do
  it { should be_file }
end

describe file("C:/tools/selenium/hub.toml") do
  it { should be_file }
end

describe file("C:/tools/selenium/hub.log") do
  it { should be_file }
end

describe service('Selenium Hub') do
  it { should be_enabled }
  it { should be_running }
end

describe port(4446) do
  it { should be_listening }
end
