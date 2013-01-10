FactoryGirl.define do
  factory :client, class: Cyberdyne::Client do
    service_name { "TestService" }

    initialize_with { new(attributes) }
  end
end