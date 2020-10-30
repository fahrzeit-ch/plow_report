# frozen_string_literal: true

require "rails_helper"


feature "resend_invitation" do
  let(:company_admin) { create(:user, skip_create_driver: true) }
  let(:company) { create(:company) }

  before do
    company.add_member(company_admin, CompanyMember::ADMINISTRATOR)
    sign_in_with(company_admin.email, company_admin.password)
    visit(company_company_members_path(company))
  end

  context "invited member without acceptance" do
    before do
      build(:company_member_invite, company: company).save_and_invite!(company_admin)
      visit(company_company_members_path(company)) # refresh the page (because we do not use javascript in spec
    end

    it "it should display invitation status" do
      expect(page).to have_content(I18n.t("views.companies.users.pending_invite"))
    end

    it "should have link to resend invitation token" do
      expect(page).to have_link(I18n.t("views.companies.users.resend_invite"))
    end

    it "should resend link when click resend" do
      expect {
        click_link(I18n.t("views.companies.users.resend_invite"))
      }.to change(ActionMailer::Base.deliveries, :count)
    end
  end
end
