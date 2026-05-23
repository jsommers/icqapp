# icqapp2

A Ruby on Rails application designed for in-class peer instruction, allowing instructors to present questions and students to respond in real-time.

## Tech Stack
- **Framework:** Ruby on Rails 8.1.3 (`config.load_defaults 8.0`)
- **Ruby:** 4.0.5
- **Database:** SQLite (Development/Test), PostgreSQL (Production)
- **Authentication:** Devise with Google OAuth2 (`omniauth-google-oauth2`). No public signup — users must be pre-seeded and the OAuth callback rejects unknown emails.
- **Frontend:** Hotwire (Turbo & Stimulus), Action Text (Trix), Sass (`sassc-rails`)
- **Real-time:** ActionCable via Redis; Turbo Streams broadcasting from models (no custom channel classes)
- **Assets:** Sprockets for CSS, Import Maps for JavaScript (`importmap-rails`)
- **Testing:** RSpec, Capybara, FactoryBot, Selenium (headless), SimpleCov, DatabaseCleaner
- **Email:** `PollNotifyMailer` for sending poll results to instructors (from `icqappjs@gmail.com`)

## Domain Model
- **User:** Authenticated via Devise/Google OAuth2. Has `admin` boolean flag. Scopes: `students` (admin: false), `instructors` (admin: true). HABTM with courses and attendances. Has many poll_responses and cold_calls.
- **Course:** The central entity. Has instructors (admin users) and students (regular users) via HABTM (`courses_users` join table). Tracks `daytime` (e.g., "MWF 10:00-10:50", validated format `[MTWRF]{2,3} H:MM-H:MM`). Key methods: `now?` (checks if in session), `active_question`, `active_poll`, `attendance_active?`, `open_attendance`/`close_attendance`. Auto-manages ColdCall records when students are added/removed.
- **Question:** Belongs to a Course. Uses `has_rich_text :content` (Action Text). Uses Single Table Inheritance (STI):
  - `FreeResponseQuestion`
  - `MultiChoiceQuestion` (content must be ≥ 5 chars)
  - `NumericQuestion`
- **Poll:** An instance of a Question being asked. Multiple polls can be created for a single question (rounds). Uses STI:
  - `FreeResponsePoll`
  - `MultiChoicePoll` (parses question content lines as options)
  - `NumericPoll`
  - Class method `closeall(course)` closes all open polls for a course.
- **PollResponse:** A student's response to a Poll. Uses STI:
  - `FreeResponsePollResponse`
  - `MultiChoicePollResponse`
  - `NumericPollResponse` (casts response to float)
- **Attendance:** Tracks student attendance for a course session. Has `active` boolean. HABTM with users (`attendances_users` join table). Method: `checked_in?(student)`.
- **ColdCall:** Tracks how many times a student has been called on in a course. Class method `random_student(course)` picks the student with minimum count and increments.

### Discussion Feature (Partially Implemented)
The database schema includes tables for `discussion_boards`, `discussion_posts`, `discussion_responses`, and `discussion_upvotes` (polymorphic), but no corresponding model files or functional controllers exist. The `app/views/discussion_upvotes/` directory exists but is empty.

## Real-time Architecture
Turbo Streams broadcasting is done directly from models (no custom ActionCable channel classes):
- **`active_question_channel`** — `Poll` broadcasts on `after_create_commit` (activate) and `after_update_commit` (deactivate)
- **`poll_responses_channel`** — `PollResponse` broadcasts response count on `after_commit`
- **`attendance_channel`** — `Attendance` broadcasts on `after_commit`

ActionCable connection identifies users via the encrypted session cookie (`_icqapp2_session["user_id"]`).

### Stimulus Controllers
- **`poll_response_controller`** — Form submission UX (spinner, success checkmark animation, timestamp)
- **`poll_result_controller`** — Toggles visibility of poll response display
- **`attendance_reload_controller`** — Reloads parent turbo-frame on connect for live updates

## Key Routes & Endpoints
```
root                                    -> courses#index
GET    /courses                         -> courses#index
GET    /courses/:id                     -> courses#show
POST   /courses/:course_id/attendance   -> attendance#create
POST   /courses/:course_id/open_attendance  -> courses#open_attendance
POST   /courses/:course_id/close_attendance -> courses#close_attendance
GET    /courses/:id/attendance_report   -> courses#attendance_report
GET    /courses/:id/question_report     -> courses#question_report
       /courses/:course_id/cold_calls   -> cold_calls#(index, edit, update)
       /courses/:course_id/questions    -> questions#(index, show, new, create, destroy)
         /questions/:question_id/polls  -> polls#(index, show, create, update, destroy)
           /polls/:poll_id/poll_responses -> poll_responses#create
POST   /polls/:id/notify               -> polls#notify (sends results email)
GET    /x                               -> courses#create_and_activate (magic route)
devise_for :users (omniauth_callbacks: users/omniauth_callbacks)
```

## Key Features & Conventions
- **Real-time Updates:** Uses Turbo Streams to broadcast poll status changes (activation/deactivation), response counts, and attendance updates to students.
- **Auto-Redirect:** Students are automatically redirected to the `show` page of a course if it is currently "in session" based on its `daytime` schedule.
- **Reporting:** Provides matrix-style reports for attendance (students × dates) and poll responses (students × polls with correctness indicators).
- **Magic Route:** `GET /x` (`CoursesController#create_and_activate`) for rapid question and poll creation via query params (`c`=course, `q`=question, `a`=answer, `o`=options, `n`=numopts, `t`=type `m`/`n`/`f`). Designed for integration with external tools (e.g., Jupyter notebooks).
- **Cold Calling:** Random student selection weighted toward least-called students. Instructor can view and edit cold call counts.
- **Poll Notification:** Instructors can email poll results via `PollNotifyMailer` (`deliver_later`).
- **Seeding:** Users (students and instructors) must be seeded; public signup is disabled. Default seed creates instructor `jsommers@colgate.edu` and student `sommersmeister@gmail.com`.

## Development Workflows
- **Testing:** Run tests with `bundle exec rspec`. Feature specs use `selenium_headless` driver.
- **Factories:** Defined in `spec/factories.rb` — `user`/`student`, `admin`, `course` (with `course_with_students` trait), `numeric_question`, `free_response_question`, `multi_choice_question`.
- **Linting:** Standard Rails conventions are followed.
- **Assets:** Uses Sprockets for CSS and Import Maps for JavaScript.
- **Database:** Development/test use SQLite (`db/development.sqlite3`, `db/test.sqlite3`). Production uses PostgreSQL (database: `icq`).
