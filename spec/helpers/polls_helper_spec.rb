require 'rails_helper'

RSpec.describe PollsHelper, type: :helper do
  context "row_class" do
    it "should return 'correct' if answer matches" do
      q = double("question")
      expect(q).to receive(:answer) { "1" }
      expect(row_class(q, "1")).to eq("correct")
    end

    it "should return empty string if answer doesn't match" do
      q = double("question")
      expect(q).to receive(:answer) { "0" }
      expect(row_class(q, "1")).to eq("")
    end
  end
end
