require 'rails_helper'

RSpec.describe PollNotifyMailer, type: :mailer do
  describe "#notify_email" do
    let(:course) { FactoryBot.create(:course) }
    let(:user) { FactoryBot.create(:student) }
    let(:question) do
      q = FactoryBot.build(:numeric_question, qname: "Q1", course: course)
      course.questions << q
      q.save
      q
    end
    let(:poll) { question.new_poll(isopen: false, round: 1).tap(&:save) }
    let(:mail) { PollNotifyMailer.with(poll: poll, user: user).notify_email }

    it "renders the subject" do
      expect(mail.subject).to eq("Poll results: Q1")
    end

    it "sends to the correct recipient" do
      expect(mail.to).to eq([user.email])
    end

    it "sends from the correct address" do
      expect(mail.from).to eq(["icqappjs@gmail.com"])
    end
  end
end
