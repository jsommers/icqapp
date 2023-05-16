require 'rails_helper'

RSpec.describe Course, type: :model do
  describe "now?" do
    it "should return false if the day doesn't match" do
      # a tuesday, midnight
      allow(Time).to receive(:now) { Time.new(2019, 5, 7, 0, 0, 0, "-05:00") }
      c = Course.new(:name => "basket weaving", :daytime => "MWF 09:20-10:10")
      expect(c.now?).to be false

      allow(Time).to receive(:now) { Time.new(2019, 5, 7, 9, 20, 0, "-05:00") }
      expect(c.now?).to be false
    end

    it "should return false if the day matches but time doesn't" do
      # monday
      allow(Time).to receive(:now) { Time.new(2019, 5, 6, 9, 0, 0, "-05:00") }
      c = Course.new(:name => "basket weaving", :daytime => "MWF 09:20-10:10")
      expect(c.now?).to be false

      allow(Time).to receive(:now) { Time.new(2019, 5, 6, 9, 19, 0, "-05:00") }
      expect(c.now?).to be false

      allow(Time).to receive(:now) { Time.new(2019, 5, 6, 10, 11, 0, "-05:00") }
      expect(c.now?).to be false
    end

    it "should return true if the day and time match" do
      allow(Time).to receive(:now) { Time.new(2019, 5, 6, 9, 20, 0, "-05:00") }
      c = Course.new(:name => "basket weaving", :daytime => "MWF 09:20-10:10")
      expect(c.now?).to be true

      allow(Time).to receive(:now) { Time.new(2019, 5, 8, 9, 20, 0, "-05:00") }
      expect(c.now?).to be true

      allow(Time).to receive(:now) { Time.new(2019, 5, 10, 9, 20, 0, "-05:00") }
      expect(c.now?).to be true

      allow(Time).to receive(:now) { Time.new(2019, 5, 10, 10, 01, 0, "-05:00") }
      expect(c.now?).to be true
    end
  end

  # describe "active question/poll" do
  #   it "should return the id of the question with an active poll" do
  #     course = Course.create(:name => "course", :daytime => "TR 9:55-10:00")
  #     q = NumericQuestion.create(:qname => "a question", :course => course)
  #     q2 = NumericQuestion.create(:qname => "question 2", :course => course)
  #     1.upto(2) do |i|
  #       q.new_poll(:isopen => false, :round => i).save!
  #       q2.new_poll(:isopen => false, :round => i).save!
  #     end
  #     q2.new_poll(:isopen => true, :round => 3).save!
  #     expect(course.active_question).to eq(q2)
  #   end

  #   it "should return nil if no poll is active" do
  #     c = Course.create(:name => "course", :daytime => "TR 9:55-10:00")
  #     q = NumericQuestion.create(:qname => "a question", :course => c)
  #     q2 = NumericQuestion.create(:qname => "another question", :course => c)
  #     1.upto(3) do |i| 
  #       q.new_poll(:isopen => false, :round => i).save!
  #       q2.new_poll(:isopen => false, :round => i).save!
  #     end
  #     expect(c.active_question).to be nil
  #   end
  # end

  # describe "attendance" do
  #   it "should correctly if attendance is taken, if it hasn't been" do
  #     c = Course.create(:name => "course", :daytime => "TR 9:55-10:00")
  #     expect(c.attendance_taken?).to be false
  #     expect(c.attendance_today).to be_nil
  #   end

  #   it "should correctly if attendance is taken, if it is in progress" do
  #     c = Course.create(:name => "course", :daytime => "TR 9:55-10:00")
  #     c.open_attendance
  #     expect(c.attendance_today).to be_an_instance_of(Attendance)
  #     expect(c.attendance_active?).to be true
  #   end

  #   it "should correctly if attendance is taken, if it is done" do
  #     c = Course.create(:name => "course", :daytime => "TR 9:55-10:00")
  #     c.open_attendance
  #     c.close_attendance
  #     expect(c.attendance_today).to be_an_instance_of(Attendance)
  #     expect(c.attendance_active?).to be false
  #   end
  # end
end
