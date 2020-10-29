# frozen_string_literal: true

require "rails_helper"

feature "Edit Tour" do
  context "as compnay admin" do
    let(:company_admin) { create(:user, skip_create_driver: true) }
    let(:company) { create(:company) }
    let(:driver) { create(:driver, company: company) }
    let(:tour) { create(:tour, driver: driver) }
    let!(:existing_drive) { create(:drive, driver: driver, tour: tour) }

    before do
      company.add_member(company_admin, CompanyMember::ADMINISTRATOR)
      sign_in_with(company_admin.email, company_admin.password)
      visit(company_tours_path(company))
    end

    it "navigates correctly" do
      click_link(I18n.t("common.edit"))
      expect(page).to have_current_path(edit_company_tour_path(company, tour))

      click_link(I18n.t("common.edit"))
      expect(page).to have_current_path(edit_company_tour_drife_path(company, tour, existing_drive))

      click_link(I18n.t("common.back"))
      expect(page).to have_current_path(edit_company_tour_path(company, tour))

      click_link(I18n.t("views.company_tours.add_drive"))
      expect(page).to have_current_path(new_company_tour_drife_path(company, tour))

      click_link(I18n.t("common.back"))
      expect(page).to have_current_path(edit_company_tour_path(company, tour))
    end

    describe "validation" do
      before { visit(edit_company_tour_drife_path(company, tour, existing_drive)) }

      it "shows validation errors" do
        fill_in("drive[start]", with: 1.hour.ago.strftime("%Y-%m-%dT%H:%M"))
        fill_in("drive[end]", with: 2.hours.ago.strftime("%Y-%m-%dT%H:%M"))
        click_on("OK")
        expect(page).to have_content("darf nicht vor der Start Zeit liegen")
        expect(page).to have_current_path(company_tour_drife_path(company, tour, existing_drive))

        fill_in("drive[end]", with: 10.minutes.ago.strftime("%H:%M"))
        click_on("OK")
        expect(page).to have_current_path(edit_company_tour_path(company, tour))
      end
    end
  end
end
