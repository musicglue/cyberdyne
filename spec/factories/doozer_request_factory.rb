FactoryGirl.define do
  factory :request, class: Cyberdyne::Doozer::Request do
    factory :rev_request do
      verb  { Cyberdyne::Doozer::Request::Verb::REV }
    end

    initialize_with { new(attributes) }
  end
end 