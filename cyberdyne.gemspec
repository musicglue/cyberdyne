# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cyberdyne/version'

Gem::Specification.new do |gem|
  gem.name          = "cyberdyne"
  gem.version       = Cyberdyne::VERSION
  gem.authors       = ["John"]
  gem.email         = ["john@musicglue.com"]
  gem.description   = %q{Write a gem description}
  gem.summary       = %q{Write a gem summary}
  gem.homepage      = ""
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake"
  gem.add_dependency "semantic_logger"
  gem.add_dependency "resilient_socket"
  gem.add_dependency "thread_safe"
  gem.add_dependency "gene_pool"
  gem.add_dependency "multi_json"
  gem.add_dependency "ruby_protobuf"
  gem.add_dependency "bson"
  gem.add_dependency "bson_ext"
  gem.add_dependency "celluloid-io"
end
