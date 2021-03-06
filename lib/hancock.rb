require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'

require 'openid'
require 'openid/store/filesystem'
require 'openid/extensions/sreg'

require 'sinatra/base'
require 'haml/engine'
require 'sass'
require 'guid'
require 'pony'

module Hancock; end

require File.expand_path(File.dirname(__FILE__)+'/models/user')
require File.expand_path(File.dirname(__FILE__)+'/models/consumer')

require File.expand_path(File.dirname(__FILE__)+'/sinatra/hancock/defaults')
require File.expand_path(File.dirname(__FILE__)+'/sinatra/hancock/sessions')
require File.expand_path(File.dirname(__FILE__)+'/sinatra/hancock/users')
require File.expand_path(File.dirname(__FILE__)+'/sinatra/hancock/openid_server')

module Hancock
  class ConfigurationError < StandardError; end

  class App < Sinatra::Base
    disable :show_exceptions

    set :sreg_params, [:email, :first_name, :last_name, :internal]

    set :provider_name, 'Hancock SSO Provider!'
    set :do_not_reply, nil
    set :smtp, { :domain => 'example.com' }

    error do
      pp env['sinatra.error']
    end

    register Sinatra::Hancock::Defaults
    register Sinatra::Hancock::Sessions
    register Sinatra::Hancock::Users
    register Sinatra::Hancock::OpenIDServer
  end
end
