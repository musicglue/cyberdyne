require 'rubygems'
require 'spork'

Spork.prefork do
  require 'rspec'
  require 'mocha/api'
  require 'factory_girl'
  require 'faker'
  require 'celluloid'

  RSpec.configure do |config|
    config.include FactoryGirl::Syntax::Methods
    config.mock_with :mocha
  end

  $LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
end

Spork.each_run do
  # This code will be run each time you run your specs.
  require 'cyberdyne'
  FactoryGirl.find_definitions
end