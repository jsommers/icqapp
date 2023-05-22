require 'rails_helper'

RSpec.describe Question, type: :model do
  describe "provide an appropriate prompt" do
    it "should prompt appropriately for numeric questions" do
      c = Course.create(:name => "course", :daytime => "TR 9:55-10:00")
      q = NumericQuestion.create(:qname => "a question", :content => "question content", :course => c)
      expect(q.prompt).to eq("Enter a number")
    end

    it "should prompt appropriately for multichoice questions" do
      c = Course.create(:name => "course", :daytime => "TR 9:55-10:00")
      q = MultiChoiceQuestion.create(:qname => "a question", :content => "one\ntwo\nthree\n", :course => c)
      expect(q.prompt).to eq("Submit response")
    end

    it "should prompt appropriately for free response questions" do
      c = Course.create(:name => "course", :daytime => "TR 9:55-10:00")
      q = FreeResponseQuestion.create(:qname => "a question", :content => "question content", :course => c)
      expect(q.prompt).to eq("Enter a text response")
    end
    
  end

  describe "#active_poll" do
    it "should return the poll that is active" do
        c = Course.create(:name => "course", :daytime => "TR 9:55-10:00")
        q = NumericQuestion.create(:qname => "a question", :content => "question content", :course => c)
        poll = q.new_poll(:isopen => true, :round => 2)
        poll.save
        p2 = q.new_poll(:isopen => false, :round => 1)
        p2.save
        expect(q.active_poll).to eq(poll)
    end

    it "should return nil if no poll is active" do
        c = Course.create(:name => "course", :daytime => "TR 9:55-10:00")
        q = NumericQuestion.create(:qname => "a question", :content => "question content", :course => c)
        p = q.new_poll(:isopen => false, :round => 1)
        p.save
        p = q.new_poll(:isopen => false, :round => 2)
        p.save
        expect(q.active_poll).to be nil
    end
  end
end
