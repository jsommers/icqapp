require 'rails_helper'

RSpec.describe "CreateAndActivates", type: :system do
  include Devise::Test::IntegrationHelpers

  before (:each) do
    admin = FactoryBot.create(:admin)
    sign_in admin
    c = FactoryBot.create(:course, name: 'COSC415F22')
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
    expect(Poll.all.count).to eq(1)
    expect(Poll.first.isopen).to be true
    expect(page.text).to match(/1: one\n2: two\n3: three\n4: four\n/)
  end
end
