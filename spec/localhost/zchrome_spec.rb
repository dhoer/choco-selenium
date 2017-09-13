describe 'Chrome' do
    before(:all) do
    @selenium = Selenium::WebDriver.for(:remote, url: "http://localhost:4446/wd/hub", desired_capabilities: :chrome)
  end

  after(:all) do
    @selenium.quit
  end

  it "Should return display resolution of #{res}" do
    @selenium.get 'http://www.whatismyscreenresolution.com/'
    element = @selenium.find_element(:id, 'resolutionNumber')
    expect(element.text).to eq('1024 x 768')
  end
end
