FactoryBot.define do
  factory :booking do
    user { nil }
    property { nil }
    check_in { "2025-08-08" }
    check_out { "2025-08-08" }
    guests_count { 1 }
    price_cents { 1 }
    currency { "MyString" }
    status { "MyString" }
    payment_status { "MyString" }
    special_requests { "MyText" }
  end
end
