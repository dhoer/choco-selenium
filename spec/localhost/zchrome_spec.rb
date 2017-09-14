require 'spec_helper'

describe 'Google Chrome' do
  before(:all) do
    @selenium = Selenium::WebDriver.for(:remote, url: "http://localhost:4446/wd/hub", desired_capabilities: :chrome)
    @resolution = '1024 x 768'
  end

  after(:all) do
    @selenium.quit
  end

  it "should return display resolution of #{@resolution}" do
    @selenium.get 'http://www.whatismyscreenresolution.com/'
    element = @selenium.find_element(:id, 'resolutionNumber')
    expect(element.text).to eq(@resolution)
  end
end
