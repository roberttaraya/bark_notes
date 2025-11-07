FactoryBot.define do
  factory :note do
    user { nil }
    title { "MyString" }
    body { "MyText" }
  end
end
