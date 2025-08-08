FactoryBot.define do
  factory :admin_audit_log do
    admin { nil }
    action { "MyString" }
    details { "" }
  end
end
