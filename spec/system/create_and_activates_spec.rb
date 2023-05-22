require 'rails_helper'

RSpec.describe "CreateAndActivates", type: :system do
  include Devise::Test::IntegrationHelpers

  before (:each) do
    @admin = FactoryBot.create(:admin)
    sign_in @admin
    @student = FactoryBot.create(:student)
    @c = FactoryBot.create(:course, name: 'COSC415F22')
    @c.instructors << @admin
    @c.students << @student
  end

  before do
    driven_by(:rack_test)
  end

  it "should successfully create and activate a multichoice question" do
    expect(Question.all.count).to eq(0)
    expect(Poll.all.count).to eq(0)
    visit '/x?c=COSC415F22&q=Which+one+of+these+is+true%3F&n=4&o=1%3A+one%0A2%3A+two%0A3%3A+three%0A4%3A+four%0A&a=three/'
    expect(Question.all.count).to eq(1)
    q = Question.find(1)
    expect(q.qname).to eq('Which one of these is true?')
    expect(q.content.to_plain_text).to eq(%q{1: one
2: two
3: three
4: four})
    # <div class=\"trix-content\">\n  1: one<br>2: two<br>3: three<br>\n</div>\n
    expect(Poll.all.count).to eq(1)
    expect(Poll.first.isopen).to be true
    #expect(page.text).to match(/1: one\n2: two\n3: three\n4: four\n/)

    sign_in @student
    visit(course_path(@c))
    expect(page.html).to match(%r{<div class="trix-content">\s*<div>1: one\s*<br>2: two\s*<br>3: three\s*<br>4: four\s*</div>\s*</div>})
  end

  it "should successfully create and active a mc question with no explicit options" do
    expect(Question.all.count).to eq(0)
    expect(Poll.all.count).to eq(0)
    visit '/x?c=COSC415F22&q=Which+one+of+these+is+true%3F&n=4'
    expect(Question.all.count).to eq(1)
    q = Question.find(1)
    expect(q.qname).to eq('Which one of these is true?')
    expect(q.content.to_plain_text).to eq(%q{A
B
C
D})
    p = Poll.first
    expect(Poll.all.count).to eq(1)
    expect(Poll.first.isopen).to be true

    sign_in @student
    visit(course_path(@c))
    expect(page.html).to match(%r{<div class="trix-content">A<br>B<br>C<br>D</div>})
    expect(page.text).to match(/ABCD/)
    choose('response_A')
    click_on('Submit response')

    sign_in @admin
    visit(course_question_poll_path(@c, q, p))
    expect(page.text).to match(/Responses: 1/)
  end

  it "should successfully create and active a numeric question" do
    visit '/x?c=COSC415F22&q=Which+one+of+these+is+true%3F&t=n&a=1'
    expect(Question.all.count).to eq(1)
    q = Question.find(1)
    expect(q.qname).to eq('Which one of these is true?')
    expect(Poll.all.count).to eq(1)
    expect(Poll.first.isopen).to be true
  end

  it "should successfully create and active a free response question" do
    visit '/x?c=COSC415F22&q=Which+one+of+these+is+true%3F&t=f&a=1'
    expect(Question.all.count).to eq(1)
    q = Question.find(1)
    expect(q.qname).to eq('Which one of these is true?')
    expect(Poll.all.count).to eq(1)
    expect(Poll.first.isopen).to be true
  end

end
