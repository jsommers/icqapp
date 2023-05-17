module PollsHelper
  def row_class(question, value)
    question.answer == value ? "correct" : ""
  end
end
