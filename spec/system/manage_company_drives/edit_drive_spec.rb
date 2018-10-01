require 'rails_helper'

feature 'Edit Drive' do

  context 'as compnay admin' do
    let(:company_admin) { create(:user, skip_create_driver: true) }
    let(:company) { create(:company) }
    let(:driver) { create(:driver, company: company) }
    let(:existing_drive) { create(:drive, driver: driver) }

    before do
      company.add_member(company_admin, CompanyMember::ADMINISTRATOR)
      sign_in_with(company_admin.email, company_admin.password)
      visit(edit_company_drife_path(company, existing_drive))
    end

    let(:old_value) { existing_drive.distance_km }
    let(:new_value) { old_value + 1 }

    it 'updates the drive and redirects back to drive list' do
      fill_in('drive[distance_km]', with: new_value)
      click_on('OK')
      expect(page).to have_current_path(company_drives_path(company))
      existing_drive.reload
      expect(existing_drive.distance_km).to eq(new_value)
    end
  end
end