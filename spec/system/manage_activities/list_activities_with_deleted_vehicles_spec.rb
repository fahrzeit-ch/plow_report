# frozen_string_literal: true

require "rails_helper"

feature "list activities" do
  let(:owner) { create(:user, skip_create_driver: true) }
  let(:company) { create(:company) }
  context "signed in" do
    before do
      company.add_member(owner, CompanyMember::OWNER)
      sign_in_with(owner.email, owner.password)
      visit(company_activities_path(company))
    end

    subject { page }

    it { is_expected.to have_content(I18n.t("views.companies.activities.title")) }
    xit { is_expected.to have_content(I18n.t("views.companies.activities.empty_info")) }
    it { is_expected.to have_link(I18n.t("views.companies.activities.new")) }

    context "with previously deleted vehicle" do
      let(:activity_with_deleted_vehicle) { create(:activity, company: company) }
      let!(:discarded_vehicle) { create(:vehicle, company: company, vehicle_activity_assignments_attributes: [{activity_id: activity_with_deleted_vehicle.id}], discarded_at: 1.hour.ago ) }

      before { visit(company_activities_path(company)) }

      it "the activity is listed and does not show the vehicle" do
        expect(page).to have_content(activity_with_deleted_vehicle.name)
        expect(page).not_to have_content(discarded_vehicle.name)
      end
    end


  end
end
