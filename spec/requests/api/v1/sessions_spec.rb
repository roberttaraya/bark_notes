require "rails_helper"

RSpec.describe "API::V1::Sessions", type: :request do
  let!(:user) { User.create!(email: "robert@example.com", password: "robert is cool") }

  def json = JSON.parse(response.body)

  it "returns token for valid credentials" do
    post "/api/v1/login", params: { email: "robert@example.com", password: "robert is cool" }
    expect(response).to have_http_status(:created)
    expect(json).to include("token")
    expect(json["token"]).to eq(user.reload.api_token)
  end

  it "rejects invalid credentials" do
    post "/api/v1/login", params: { email: "robert@example.com", password: "this is the wrong password" }
    expect(response).to have_http_status(:unauthorized)
    expect(json).to eq({ "error" => "invalid credentials" })
  end
end
