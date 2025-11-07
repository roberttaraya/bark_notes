require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it "requires an email" do
      u = User.new(password: "pa&&word")
      expect(u).not_to be_valid
      expect(u.errors[:email]).to include("can't be blank")
    end

    it "requires a unique email" do
      User.create!(email: "u@example.com", password: "pa&&word")
      dup = User.new(email: "u@example.com", password: "pa&&word")
      expect(dup).not_to be_valid
      expect(dup.errors[:email]).to include("has already been taken")
    end
  end

  describe 'authentication' do
    it "uses has_secure_password for authentication" do
      u = User.create!(email: "p@example.com", password: "pa&&word")
      expect(u.authenticate("pa&&word")).to be_truthy
      expect(u.authenticate("password")).to be_falsey
    end

    it "generates api_token automatically" do
      u = User.create!(email: "t@example.com", password: "pa&&word")
      expect(u.api_token).to be_present
    end
  end

  describe 'relationships' do
    it "has many notes (dependent destroy)" do
      u = User.create!(email: "d@example.com", password: "pa&&word")
      n1 = u.notes.create!(title: "T1", body: "B1")
      n2 = u.notes.create!(title: "T2", body: "B2")
      expect(u.notes).to match_array([ n1, n2 ])
      u.destroy
      expect(Note.where(id: [ n1.id, n2.id ])).to be_empty
    end
  end
end
