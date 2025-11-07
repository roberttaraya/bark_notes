# README

This project implements a Rails 7.2 JSON API for managing user notes, built fully TDD-style using RSpec and FactoryBot. It delivers complete, production-quality CRUD functionality with authenticated access via Bearer tokens.

Review the [Readme](https://gist.github.com/brandonhilkert/76f8f273d33995762e04c48c38aa9c04)

Core endpoints:

- POST /api/v1/login – Authenticates a user and returns a bearer token.
- GET /api/v1/notes – Lists all notes belonging to the authenticated user.
- GET /api/v1/notes/:id – Retrieves a single note owned by the authenticated user.
- POST /api/v1/notes – Creates a new note for the authenticated user.
- PATCH /api/v1/notes/:id – Updates a note’s title or body.
- DELETE /api/v1/notes/:id – Deletes a note owned by the authenticated user.

Every endpoint is covered by request specs validating:

- Auth enforcement (401 Unauthorized)
- User scoping (404 Not Found for cross-user access)
- Validations and error responses (422 Unprocessable Content)
- Happy-path success cases (200/201/204)

All code was developed iteratively with red-green-refactor commits, favoring Rails conventions over abstraction layers.

Final suite: 25 request specs, all green, zero deprecations, minimal dependencies.

### Auth

All endpoints require Bearer token auth.

- Obtain a token via `POST /api/v1/login` with email/password.
- Send `Authorization: Bearer <token>` on requests.

### Endpoints

#### POST /api/v1/login

- Request: `{ "email": "user@example.com", "password": "pa$$word" }`
- Response: `{ "token": "..." }`

#### GET /api/v1/notes

- 200 OK → `[{ id, title, body }, ...]` (scoped to current user)

#### GET /api/v1/notes/:id

- 200 OK → `{ id, title, body }`
- 404 Not Found if not owned by current user

#### POST /api/v1/notes

- Request: `{ "title": "This is a New Note", "body": "This is my note." }`
- 201 Created → `{ id, title, body }`
- 422 Unprocessable Content → `{ errors: { title: ["can't be blank"] } }`

#### PATCH /api/v1/notes/:id

- Request: `{ "title": "Change the Title", "body": "I can change the body or not." }`
- 200 OK → `{ id, title, body }`
- 404 Not Found if not owned
- 422 Unprocessable Content with errors

#### DELETE /api/v1/notes/:id

- 204 No Content on success
- 404 Not Found if not owned

# Design Decisions

I kept things fast, simple, and true to Rails conventions. Authentication runs through a straightforward Bearer token check in Api::V1::BaseController, and every note is scoped to current_user so there’s zero chance of cross-user data leaks. If a user tries to access someone else’s note, they just get a clean 404—no hints about what exists. Responses stick to the essentials—id, title, and body—using as_json(only: …) to keep the contract explicit and avoid drifting fields. Everything lives in one controller for now—no extra layers or abstractions—since the goal was to move fast, stay focused, and deliver a solid, conventional API. Every endpoint was built from a request spec first (happy paths: 201/200/204, error paths: 401/404/422) and coded only as far as needed to make those pass.

I skipped the over-engineering on purpose: no responders, policies, or serializers—just clean Rails. Strong params allow partial updates for PATCH, while the model enforces title presence. Error responses are consistent ({ errors: { field: [messages] } }), so the front end knows exactly what to expect. It’s lean, readable, and test-driven—the smallest deployable slice that still feels production-ready.

# Future Improvements

I'm a big fan of David Copeland and his book Sustainable Web Development with Rails. If this project kept growing, I’d start introducing a lightweight service layer like David Copeland describes in his book. The goal wouldn’t be to chase patterns, but to keep controllers and models focused on their jobs, and to give business logic a clear, testable home. Controllers would stay lean...handle HTTP, params, and responses. Models would own data and validations. Anything that starts coordinating multiple responsibilities, like saving data and sending a notification or triggering an async job, would move into a service object—something like `Notes::CreateNote.new(user, params).run`.

Each service would handle a single use-case, wrap its own transaction, and return a simple result object (success?, errors, payload). That keeps business logic predictable and easy to test without hitting controllers or the database unnecessarily. It also makes it easier to layer in features later—background jobs, analytics, audit logging—without tangling the controller. I’d add these gradually, only when the app’s complexity starts to justify it.

# Thank You

Thanks for allowing me to show you my skills. I kept the code clean, readable, and true to Rails conventions...no unnecessary layers, just clean behavior backed by tests. I built it the way I’d approach a real feature at work: start with a failing spec, ship the smallest thing that works, and refine from there. I appreciate you taking the time to review it and I’m looking forward to moving on to the next step in the process.
