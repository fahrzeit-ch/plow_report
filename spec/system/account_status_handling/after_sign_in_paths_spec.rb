require 'rails_helper'


feature 'after sign in paths' do
  let(:user) { create(:user) }

  context 'user with driver' do
    it 'should open driver dashboard' do
      sign_in_with(user.email, user.password)
      expect(page).to have_content(I18n.t('dashboard.cards.new_drive.create'))
    end
  end

  context 'user without driver' do
    before { user.drivers.destroy_all }
    it 'should show empty dashboard with option to create driver or company' do
      sign_in_with(user.email, user.password)
      expect(page).to have_content(I18n.t('views.setup.instructions'))
    end

    it 'should be possible to create company from here' do
      sign_in_with(user.email, user.password)
      click_link(I18n.t('views.setup.create_company'))
      fill_form 'company_registration', attributes_for(:company)
      check('company_registration[add_owner_as_driver]')
      click_button(I18n.t('common.create'))
      expect(page).to have_current_path company_dashboard_path(Company.last)
    end

    it 'should be possible to crete personal driver' do
      sign_in_with(user.email, user.password)
      click_link(I18n.t('views.setup.create_driver'))
      expect(page).to have_current_path root_path
    end

    context 'with company membership' do
      let(:company) { create(:company) }
      before { company.add_member(user, CompanyMember::OWNER)}

      before { sign_in_with(user.email, user.password) }

      it 'should redirect to company page' do
        expect(page).to have_current_path company_dashboard_path(company)
      end

      it 'should not have link "my data"' do
        expect(page).not_to have_content(I18n.t('navbar.main.my_dashboard'))
      end

    end
  end

end