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
    visit '/x?c=COSC415F22&q=Which+of+the+following+statements+is+FALSE+regarding+HTML+and%2For+CSS%3F&n=4&o=1%3A+CSS+is+generally+concerned+with+document+styling+%28fonts%2C+colors%2C+layout%2C+etc.%29%0A2%3A+A+CSS+file+can+be+included+using+a+%3Clink%3E+element+in+the+%3Chead%3E+section+of+an+HTML+page%0A3%3A+CSS+directives+should+mainly+be+specified+within+%3Cstyle%3E+...+%3C%2Fstyle%3E+tags+in+an+HTML+page+%0A4%3A+HTML+is+concerned+with+document+structure'
    expect(Question.all.count).to eq(1)
    expect(Poll.all.count).to eq(1)
    expect(Poll.first.isopen).to be true
  end

end
