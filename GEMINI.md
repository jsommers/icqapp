# icqapp2

A Ruby on Rails 7 application designed for in-class peer instruction, allowing instructors to present questions and students to respond in real-time.

## Tech Stack
- **Framework:** Ruby on Rails 7.1.3
- **Ruby:** 3.3.1
- **Database:** SQLite (Development/Test), PostgreSQL (Production)
- **Authentication:** Devise with Google OAuth2 (`omniauth-google-oauth2`)
- **Frontend:** Hotwire (Turbo & Stimulus), Action Text (Trix), Sass
- **Testing:** RSpec, Capybara, FactoryBot, Selenium

## Domain Model
- **Course:** The central entity. Has instructors (admin users) and students (regular users). Tracks `daytime` (e.g., "MWF 10:00-10:50").
- **Question:** Belongs to a Course. Uses Single Table Inheritance (STI):
  - `FreeResponseQuestion`
  - `MultiChoiceQuestion`
  - `NumericQuestion`
- **Poll:** An instance of a Question being asked. Multiple polls can be created for a single question (rounds). Also uses STI:
  - `FreeResponsePoll`
  - `MultiChoicePoll`
  - `NumericPoll`
- **PollResponse:** A student's response to a Poll. Uses STI:
  - `FreeResponsePollResponse`
  - `MultiChoicePollResponse`
  - `NumericPollResponse`
- **Attendance:** Tracks student attendance for a course session.
- **ColdCall:** Tracks how many times a student has been called on in a course.

## Key Features & Conventions
- **Real-time Updates:** Uses Turbo Streams to broadcast poll status changes (activation/deactivation) to students.
- **Auto-Redirect:** Students are automatically redirected to the `show` page of a course if it is currently "in session" based on its `daytime` schedule.
- **Reporting:** Provides matrix-style reports for attendance and poll responses.
- **Magic Routes:** Contains an endpoint `/x` (`CoursesController#create_and_activate`) for rapid question and poll creation via external tools.
- **Seeding:** Users (students and instructors) must be seeded; public signup is disabled.

## Development Workflows
- **Testing:** Run tests with `bundle exec rspec`.
- **Linting:** Standard Rails conventions are followed.
- **Assets:** Uses Sprockets for CSS and Import Maps for JavaScript.
