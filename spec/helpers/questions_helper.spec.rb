require 'rails_helper'

RSpec.describe QuestionsHelper, type: :helper do
  describe "question_type" do
    it "should give text before Question" do
      expect(question_type("XQuestion").to eq("X")
    end
  end

  describe "question_types" do
    it "should give the right list" do
      expect(question_types).to eq(%w{NumericQuestion MultiChoiceQuestion FreeResponseQuestion})
    end
  end
end
