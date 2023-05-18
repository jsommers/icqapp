class PollNotifyMailer < ApplicationMailer
  default from: 'icqappjs@gmail.com'

  def notify_email
    poll = params[:poll]
    user = params[:user]
    @question = poll.question.qname
    @user = user.email
    @results = poll.responses
    mail(to: @user, subject: "Poll results: #{@question}")
  end
end
