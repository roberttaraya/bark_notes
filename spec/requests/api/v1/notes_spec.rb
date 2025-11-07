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

  it "shows a single note" do
    note = user.notes.first
    get "/api/v1/notes/#{note.id}", headers: { "Authorization" => bearer(user.api_token) }
    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body["id"]).to eq(note.id)
    expect(body["title"]).to eq(note.title)
    expect(body["body"]).to eq(note.body)
  end

  it "404s for a note not owned by current user" do
    note = other.notes.create!(title: "Nope", body: "N/A")
    get "/api/v1/notes/#{note.id}", headers: { "Authorization" => bearer(user.api_token) }
    expect(response).to have_http_status(:not_found)
  end
end
