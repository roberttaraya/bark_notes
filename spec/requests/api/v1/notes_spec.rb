require "rails_helper"

RSpec.describe "API::V1::Notes", type: :request do
  let!(:user)  { User.create!(email: "robert@example.com", password: "this is my password") }
  let!(:other) { User.create!(email: "zara@example.com", password: "this is zara's password") }

  before do
    user.notes.create!(title: "T1", body: "B1")
    user.notes.create!(title: "T2", body: "B2")
    other.notes.create!(title: "X",  body: "Y")
  end

  def bearer(token) = "Bearer #{token}"

  it "requires auth" do
    get "/api/v1/notes"
    expect(response).to have_http_status(:unauthorized)
  end

  it "lists only current user's notes" do
    get "/api/v1/notes", headers: { "Authorization" => bearer(user.api_token) }
    expect(response).to have_http_status(:ok)
    titles = JSON.parse(response.body).map { |n| n["title"] }
    expect(titles).to contain_exactly("T1", "T2")
  end
end
