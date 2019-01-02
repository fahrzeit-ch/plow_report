require 'rails_helper'

feature 'assign user to existing driver' do
  let(:company) { create(:company) }
  let(:owner) { create(:user) }
  let(:other_member) { create(:company_member, company: company, role: :owner) }

  let(:driver) { create(:driver, company: company) }

  before do
    driver
    other_member
    company.add_member(owner, :owner)
    sign_in_with(owner.email, owner.password)
    visit "/companies/#{company.id}/drivers"
  end

  it 'click assign user links the driver with the selected user' do
    click_link(I18n.t('views.companies.drivers.edit'))
    find('#driver_user').find(:xpath, 'option[2]').select_option
    find('[name=commit]').click
    expect(page).to have_current_path("/companies/#{company.to_param}/drivers")
  end

end