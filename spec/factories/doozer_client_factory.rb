FactoryGirl.define do
  factory :doozer_client, class: Cyberdyne::Doozer::Client do
    
    factory :complex_doozer_client do
      read_timeout            10
      connect_timeout         5
      connect_retry_interval  1
      connect_retry_count     5
      server                  "localhost:8046"
    end

    initialize_with { new(attributes) }
  end
end