require 'spec_helper'

describe file('C:/tools/selenium') do
  it { should be_directory }
end

describe file("C:/tools/selenium/selenium-server-standalone.jar") do
  it { should be_file }
end

describe file("C:/tools/selenium/nodeconfig.json") do
  it { should be_file }
end

describe file("C:/tools/selenium/node.cmd") do
  it { should be_file }
end

describe file("C:/tools/selenium/node.log") do
  it { should be_file }
end

describe file("$HOME/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Selenium/Selenium Node.lnk") do
  it { should be_file }
end

describe file("$HOME/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup/Selenium Node.lnk") do
  it { should be_file }
end

describe port(5557) do
  it { should be_listening }
end
