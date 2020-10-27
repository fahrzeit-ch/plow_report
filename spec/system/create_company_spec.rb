require 'rails_helper'

feature 'create company' do

  let(:owner) { create(:user, skip_create_driver: true) }

  context 'signed in' do
    before do
      sign_in_with(owner.email, owner.password)
      visit(new_company_path)
    end

    it do
      expect(page).to have_content(I18n.t('views.companies.new.title'))
    end


    it 'will create new company' do
      fill_form('company_registration', attributes_for(:company_registration))
      click_button(I18n.t('views.companies.new.create'))
      expect(page).to have_content(I18n.t('views.companies.dashboard.title'))
    end

  end

end