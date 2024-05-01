require 'rails_helper'

RSpec.describe CoursesHelper, type: :helper do
  context 'strip_email_domain' do
    it 'should strip @colgate.edu' do
      expect(strip_email_domain('jsommers@colgate.edu')).to eq('jsommers')
    end
  end
end
