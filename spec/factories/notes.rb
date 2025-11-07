FactoryBot.define do
  factory :note do
    association :user
    title { "This is a Note" }
    body  { "This is the body of the note." }
  end
end
