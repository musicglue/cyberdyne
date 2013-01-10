require 'spec_helper'

describe Cyberdyne::Client do
  subject { build :client }
  its(:logger) { should be_a(SemanticLogger::Logger) }
end