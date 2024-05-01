module CoursesHelper
  def strip_email_domain(email)
    email.gsub(/@colgate\.edu$/, '')
  end
end
