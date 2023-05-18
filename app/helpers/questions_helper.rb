module QuestionsHelper
  def student_responses(q)
    rr = PollResponse.joins(:poll).where("polls.question_id" => q.id).where("poll_responses.user_id" => current_user).select(:response)
    if rr.length == 0
      "No responses"
    else
      out = rr.collect {|rec| rec.response}.join(',')
      "#{rr.length} response: #{out}"
    end
  end

  def question_type(t)
    t =~ /^(\w+)Question$/ 
    $1.capitalize
  end

  def question_icon(t)
    t =~ /^(\w+)Question$/ 
    t = $1.downcase.to_sym
    icons = {'multichoice': 'list-ordered', 'numeric': 'graph', 'freeresponse': 'quote'}
    icons[t]
  end

  def question_types
    %w{MultiChoiceQuestion NumericQuestion FreeResponseQuestion}
  end

  def question_input(q, currresponse)
    curr = currresponse ? currresponse.response : ""
    case q.type
      when "MultiChoiceQuestion"
        s = ""
        q.content.to_plain_text.each_line do |opt|
          h = {:class => "form-check-input"}
          t = radio_button_tag('response', opt, opt == curr, **h)
          t += label_tag(opt, opt)
          s = s + "<div class='form-check'>" + t + "</div>"
        end
        s.html_safe
      when "NumericQuestion"
        number_field_tag :response, curr, :step => 0.01, :class => "form-control"
      when "FreeResponseQuestion"
        text_field_tag :response, curr, :class => "form-control"
    end
  end
end
