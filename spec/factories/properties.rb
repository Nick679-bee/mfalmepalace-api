FactoryBot.define do
  factory :property do
    name { "MyString" }
    property_type { "MyString" }
    description { "MyText" }
    max_guests { 1 }
    amenities { "" }
    distance_to_airport_minutes { 1 }
    pet_friendly { false }
    eco_friendly { false }
    photos { "MyText" }
  end
end
