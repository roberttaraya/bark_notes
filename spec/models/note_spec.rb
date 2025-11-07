require 'rails_helper'

RSpec.describe Note, type: :model do
  let(:user) { User.create!(email: "u@example.com", password: "password") }

  describe 'validations' do
    it "requires title" do
      note = described_class.new(user: user, body: "Body")
      expect(note).not_to be_valid
      expect(note.errors[:title]).to include("can't be blank")
    end

    it "belongs to a user" do
      note = described_class.new(title: "T", body: "B")
      expect(note).not_to be_valid
      expect(note.errors[:user]).to be_present

      note.user = user
      expect(note).to be_valid
    end
  end
end
