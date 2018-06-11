require 'rails_helper'

feature 'redirect user to company when no driver' do
  let(:user) { create(:user, skip_create_driver: true) }
  let(:company) { create(:company) }
  let(:pages) { %w(/drives /standby_dates /) }

  before do
    company.add_member(user, CompanyMember::ADMINISTRATOR)
    sign_in_with(user.email, user.password)
  end

  it 'should redirect all driver pages' do
    pages.each do |url|
      visit(url)
      expect(page).to have_current_path(company_dashboard_path(company))
    end
  end

end