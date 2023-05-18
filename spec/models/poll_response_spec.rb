require 'rails_helper'

RSpec.describe PollResponse, type: :model do
  describe "free poll response" do
    it "should associate question/poll/poll response correctly for free response" do
      c = FactoryBot.create(:course)
      q = Question.new(:type => "FreeResponseQuestion", :content => %w{one two three}.join('\n'), :qname => "free response question")
      c.questions << q
      q.save
      p = q.new_poll
      p.save
      fr = p.new_response(:response => "random text")
      fr.save
      expect(fr.poll).to eq(p)
    end
  end

  describe "numeric poll response" do
    it "should return a float for the response" do
      c = FactoryBot.create(:course)
      q = Question.new(:type => "NumericQuestion", :content => %w{one two three}.join('\n'), :qname => "numeric question")
      c.questions << q
      q.save
      p = q.new_poll
      p.save
      r = p.new_response(:response => "3.5")
      r.save
      expect(r.response).to eq(3.5)
    end
  end

  describe "multichoice poll response" do
    it "should give the index of the response" do
      c = FactoryBot.create(:course)
      q = Question.new(:type => "MultiChoiceQuestion", :qname => "numeric question", :content => %w{one two three}.join('\n'))
      c.questions << q
      q.save
      p = q.new_poll
      p.save
      r = p.new_response(:response => "two")
      r.save
      expect(r.response).to eq("two")
    end
  end
end
