FactoryBot.define do
  factory :payment do
    booking { nil }
    provider { "MyString" }
    provider_payment_id { "MyString" }
    amount_cents { 1 }
    status { "MyString" }
    metadata { "" }
  end
end
