require "rails_helper"

RSpec.describe "API::V1::Notes", type: :request do
  let!(:user)  { create(:user) }
  let!(:other) { create(:user) }

  let!(:user_notes) do
    [
      create(:note, user: user, title: "T1", body: "B1"),
      create(:note, user: user, title: "T2", body: "B2")
    ]
  end
  let!(:others_note) { create(:note, user: other, title: "X", body: "Y") }

  def bearer(token) = "Bearer #{token}"

  def json_headers(token = nil)
    h = { "CONTENT_TYPE" => "application/json" }
    h["Authorization"] = bearer(token) if token
    h
  end

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

  describe "POST /api/v1/notes" do
    context "with valid params" do
      let(:note_title) { "this is a new note" }
      let(:note_body) { "this is the note body" }
      let(:payload) { { title: note_title, body: note_body } }

      it "creates a note for the current_user and returns 201 with id/title/body" do
        expect {
          post "/api/v1/notes", params: payload.to_json, headers: json_headers(user.api_token)
        }.to change { Note.where(user_id: user.id).count }.by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json).to include("id", "title", "body")
        expect(json["title"]).to eq(note_title)
        expect(json["body"]).to  eq(note_body)

        note = Note.find(json["id"])
        expect(note.user_id).to eq(user.id)
      end
    end

    context "with invalid params" do
      let(:payload) { { title: "" } }

      it "returns 422 with validation errors" do
        expect {
          post "/api/v1/notes", params: payload.to_json, headers: json_headers(user.api_token)
        }.not_to change { Note.count }

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json).to include("errors")
        expect(json["errors"]).to include("title")
        expect(json["errors"]["title"]).to be_present
      end
    end

    context "without auth" do
      it "returns 401" do
        post "/api/v1/notes", params: { title: "X" }.to_json, headers: json_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH /api/v1/notes/:id" do
    let!(:note) { user_notes.first }

    context "with valid params" do
      let(:note_title) { "this is a new note" }
      let(:note_body) { "this is the note body" }

      it "updates title and body for the current_user and returns 200" do
        patch "/api/v1/notes/#{note.id}",
              params: { title: note_title, body: note_body }.to_json,
              headers: json_headers(user.api_token)

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["title"]).to eq(note_title)
        expect(body["body"]).to  eq(note_body)
        expect(note.reload.title).to eq(note_title)
      end
    end

    context "with invalid params" do
      it "returns 422 with validation errors" do
        patch "/api/v1/notes/#{note.id}",
              params: { title: "" }.to_json,
              headers: json_headers(user.api_token)

        expect(response).to have_http_status(:unprocessable_content)
        body = JSON.parse(response.body)
        expect(body).to include("errors")
        expect(body["errors"]).to include("title")
      end
    end

    context "note is not the user's note" do
      let!(:imposter) { create(:note, user: other, title: "is this right?", body: "no this is not right") }

      it "returns 404" do
        patch "/api/v1/notes/#{imposter.id}",
              params: { title: "i got hacked" }.to_json,
              headers: json_headers(user.api_token)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "without auth" do
      it "returns 401" do
        patch "/api/v1/notes/#{note.id}",
              params: { title: "no way" }.to_json,
              headers: json_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/v1/notes/:id" do
    let!(:note) { create(:note, user: user, title: "ive been deleted", body: "bye") }

    it "deletes the note and returns 204 for current_user" do
      expect {
        delete "/api/v1/notes/#{note.id}", headers: json_headers(user.api_token)
      }.to change { Note.where(user_id: user.id).count }.by(-1)

      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_blank
    end

    it "returns 404 when deleting someone else's note" do
      imposter = create(:note, user: other)
      delete "/api/v1/notes/#{imposter.id}", headers: json_headers(user.api_token)
      expect(response).to have_http_status(:not_found)
    end

    it "returns 401 without auth" do
      delete "/api/v1/notes/#{note.id}", headers: json_headers
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
