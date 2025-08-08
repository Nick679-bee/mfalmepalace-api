FactoryBot.define do
  factory :price_override do
    property { nil }
    date { "2025-08-08" }
    price_cents { 1 }
    is_blackout { false }
  end
end
