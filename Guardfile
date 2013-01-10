# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :bundler do
  watch('Gemfile')
  watch(/^.+\.gemspec/)
end

guard :spork, :rspec_env => { 'RACK_ENV' => 'test' } do
  watch(%r{^config/initializers/.+\.rb$})
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb') { :rspec }
end

guard :rspec, cli: '--drb --color --format progress' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})               { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')            { "spec" }
  watch(%r{^spec/support/(.+)\.rb$})      { "spec" }
end