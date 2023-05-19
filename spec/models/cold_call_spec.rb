require 'rails_helper'

RSpec.describe ColdCall, type: :model do
  context "random student selection per course" do
    before :each do 
      @c = Course.new(:name => "basket weaving", :daytime => "MWF 09:20-10:10")
      @c.save!
      @s1 = User.new(:email => "student1@student.info", :admin => false)
      @s1.save!
      @s2 = User.new(:email => "student2@student.info", :admin => false)
      @s2.save!
      @c.students << @s1
      @c.students << @s2
    end

    it "should set coldcall count to 0 when student is added to class" do
      expect(ColdCall.where(course: @c, user: @s1).first.count).to eq(0)
      expect(ColdCall.where(course: @c, user: @s2).first.count).to eq(0)
    end

    it "should initialize a coldcall record if student hasn't been called on" do
      expect(ColdCall.count).to eq(@c.students.count)
      s = ColdCall.random_student(@c)
      expect(ColdCall.where(course: @c).sum(:count)).to eq(1)
    end

    it "should increment coldcall record if student is called on again" do
      @c.students.delete @s2
      s = ColdCall.random_student(@c)
      s = ColdCall.random_student(@c)
      expect((ColdCall.where(course: @c, user: s).first).count).to eq(2)
    end

    it "should cycle through students so everyone is called on once before being called a second time" do
      expect(ColdCall.count).to eq(@c.students.count)
      4.times do 
        ColdCall.random_student(@c)
      end
      expect(ColdCall.all.pluck('count')).to eq([2,2])
    end
  end
end
