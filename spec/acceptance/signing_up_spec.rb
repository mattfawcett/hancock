require File.expand_path(File.dirname(__FILE__)+'/../spec_helper')

describe "visiting /sso/signup" do
  before(:each) do
    @user = Hancock::User.new(:email      => /\w+@\w+\.\w{2,3}/.gen.downcase,
                              :first_name => /\w+/.gen.capitalize,
                              :last_name  => /\w+/.gen.capitalize)
  end
  if ENV['WATIR']
    begin
      require 'safariwatir'
      describe "with no valid browser sessions" do
        before(:each) do
          @sso_server = 'http://hancock.atmos.org/sso'
          @browser = Watir::Safari.new
          @browser.goto("http://localhost:5000/sso/logout")
        end
        it "should browse properly in safari" do
          # session cookie fails on localhost :\
          # sso_server = 'http://localhost:20000/sso'

          # make a request and signup to access the site
          @browser.goto('http://localhost:5000/')
          @browser.link(:url, "#{@sso_server}/signup").click
          @browser.text_field(:name, :first_name).set(@user.first_name)
          @browser.text_field(:name, :last_name).set(@user.last_name)
          @browser.text_field(:name, :email).set(@user.email)
          @browser.button(:value, 'Signup').click

          # hacky way to strip this outta the markup in development mode
          register_url = @browser.html.match(%r!#{@sso_server}/register/\w{40}!).to_s
          register_url.should_not be_nil
          password = /\w+{9,32}/.gen

          # register from the url from their email
          @browser.goto(register_url)
          @browser.text_field(:name, :password).set(password)
          @browser.text_field(:name, :password_confirmation).set(password)
          @browser.button(:value, 'Am I Done Yet?').click

          sleep 2

          # sent back to be greeted on the consumer
          @browser.html.should match(%r!Hancock Client: Sinatra!)
          @browser.html.should have_selector("h2 a[href='mailto:#{@user.email}']:contains('#{@user.first_name} #{@user.last_name}')")
        end
      end
    rescue; end
  end
end
