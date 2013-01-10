`git ls-files`.split("\n")
              .select{ |m| m =~ /^lib\/cyberdyne\/\w+\.rb/ }
              .each{ |file| require file.gsub("lib/", "").gsub(".rb", "") }

module Cyberdyne

  # Your code goes here...
end
