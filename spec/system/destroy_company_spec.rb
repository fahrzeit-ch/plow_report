require 'rails_helper'

feature 'delete company' do

  let(:owner) { create(:user, skip_create_driver: true) }
  let(:company) { create(:company) }

  before { company.add_member(owner, CompanyMember::OWNER) }

  context 'signed in as company owner' do
    before do
      sign_in_with(owner.email, owner.password)
      visit(edit_company_path(company))
    end

    it do
      expect(page).to have_content(I18n.t('views.companies.edit.destroy_company'))
    end

    context 'owner has not personal driver' do
      before { click_link_or_button(I18n.t('views.companies.edit.destroy_company')) }

      it 'will redirect to setup page' do
        expect(page).to have_current_path(setup_path)
      end
    end

  end

end