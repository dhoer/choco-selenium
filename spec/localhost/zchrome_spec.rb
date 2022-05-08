require 'spec_helper'

# describe 'Google Chrome' do
#   before(:all) do
#     @driver = Selenium::WebDriver.for(:remote, url: "http://localhost:4446/wd/hub", desired_capabilities: :chrome)
#     @wait = Selenium::WebDriver::Wait.new(:timeout => 10)
#     @driver.get "http://google.com"
#   end

#   after(:all) do
#     @driver.quit
#   end

#   it 'should Google Search for Cheese!' do
#     element = @driver.find_element :name => 'q'
#     element.send_keys 'Cheese!'
#     element.submit

#     @wait.until { @driver.title.downcase.start_with? 'cheese!' }
#   end
# end
