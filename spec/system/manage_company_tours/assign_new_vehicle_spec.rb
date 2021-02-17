# frozen_string_literal: true

require "rails_helper"

feature "Assign new vehicle to tour", type: :system  do
  context "without previous vehicle" do
    let(:company_admin) { create(:user, skip_create_driver: true) }
    let(:company) { create(:company) }
    let(:driver) { create(:driver, company: company) }

    let(:tour) { create(:tour, driver: driver) }
    let(:old_activity) { create(:activity, company: company) }
    let(:new_activity) { create(:activity, company: company) }

    let!(:new_vehicle) { create(:vehicle, company: company) }

    let!(:existing_drive_with_affected_activity) { create(:drive, driver: driver, tour: tour, activity: old_activity) }

    before do
      company.add_member(company_admin, CompanyMember::ADMINISTRATOR)
      sign_in_with(company_admin.email, company_admin.password)
      visit(edit_company_tour_path(company, tour))
      new_vehicle.vehicle_activity_assignments.create activity_id: new_activity.id
    end

    it "is possible to assign new vehicle", js: true do
      click_on(I18n.t('actions.change'))
      expect(page).to have_content(I18n.t('views.company_tours.assign_new_vehicle'))

      within "#dynamicModal" do
        click_button("button")
      end

      expect(page).to have_content(I18n.t('activemodel.attributes.activity_replacement.new_activity_id'))
      find('option[value="' + new_activity.id.to_s + '"]').select_option

      within "#dynamicModal" do
        click_button("button")
      end
      expect(page).to have_content(I18n.t('flash.vehicle_reassignments.reassigned'))
    end
  end
end
