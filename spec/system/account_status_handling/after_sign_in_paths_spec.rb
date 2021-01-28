# frozen_string_literal: true

require "rails_helper"


feature "after sign in paths" do
  let(:user) { create(:user) }

  context "user with driver on company without membership" do
    let(:company) { create(:company) }
    let(:driver) { create(:driver, company: company) }

    before { user.drivers << driver }

    it "should actually never really happen" do
      sign_in_with(user.email, user.password)
      expect(page).to have_content(I18n.t("views.static_pages.account_error.title"))
    end
  end

  context "user with driver on company" do
    let(:company) { create(:company) }

    before { company.add_member(user, CompanyMember::DRIVER) }

    it "should actually never really happen" do
      sign_in_with(user.email, user.password)
      expect(page).to have_content(I18n.t("views.companies.dashboard.title"))
    end
  end

  context "user without driver" do
    it "should redirect to setup page" do
      sign_in_with(user.email, user.password)
      expect(page).to have_current_path(setup_path)
      expect(page).to have_content(I18n.t("views.setup.use_as_driver_title"))
    end

    it "should be possible to create company from here" do
      sign_in_with(user.email, user.password)
      click_on(I18n.t("views.setup.create_company"))
      fill_form "company_registration", attributes_for(:company).except(:options)
      check("company_registration[add_owner_as_driver]")
      click_button(I18n.t("views.companies.new.create"))
      expect(page).to have_current_path company_dashboard_path(Company.last)
    end

    context "with company membership" do
      let(:company) { create(:company) }
      before { company.add_member(user, CompanyMember::OWNER) }

      before { sign_in_with(user.email, user.password) }

      it "should redirect to company page" do
        expect(page).to have_current_path company_dashboard_path(company)
      end

      it 'should not have link "my data"' do
        expect(page).not_to have_content(I18n.t("navbar.main.my_dashboard"))
      end
    end
  end
end
