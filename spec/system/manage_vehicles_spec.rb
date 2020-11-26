# frozen_string_literal: true

require "rails_helper"

feature "create company" do
  let(:owner) { create(:user, skip_create_driver: true) }
  let(:company) { create(:company) }
  let!(:activities) { create_list(:activity, 2, company: company) }

  context "signed in" do
    before do
      company.add_member(owner, CompanyMember::OWNER)
      sign_in_with(owner.email, owner.password)
      visit(company_vehicles_path(company))
    end

    subject { page }

    it { is_expected.to have_content(I18n.t("views.vehicles.title")) }
    it { is_expected.to have_content(I18n.t("views.vehicles.empty_info")) }
    it { is_expected.to have_link(I18n.t("views.vehicles.create_new")) }

    describe "create new vehicle", js: true do
      it "is possible to create a new vehicle from the index page" do
        click_link(I18n.t("views.vehicles.create_new"))
        expect(page).to have_content(I18n.t("views.vehicles.new_title"))

        # We fill in the form for new vehicle and save it
        fill_in("vehicle[name]", with: "My Vehicle")
        click_on(I18n.t("views.vehicles.add_activity"))
        within '.nested-fields:nth-child(1)' do
          select activities.first.name, from: "Activity"
        end
        click_on(I18n.t("actions.save"))

        # We are redirected back to index page and can see the newly created vehicle
        expect(page).to have_current_path(company_vehicles_path(company))
        expect(page).to have_content("My Vehicle")
        expect(page).to have_content(activities.first.name)
      end
    end

    context "existing vehicle" do
      let!(:existing_vehicle) { create(:vehicle, company: company, activities: activities)}
      before { visit(company_vehicles_path(company)) }
      subject { page }
      it { is_expected.to have_content(existing_vehicle.name) }

      describe "edit existing", js: true do
        it "is possible to edit an existing vehicle" do
          # we can edit the existing vehicle
          click_link(I18n.t("common.edit"))
          expect(page).to have_content(I18n.t("views.vehicles.edit_title"))

          within '.nested-fields:nth-child(1)' do
            click_link('X')
          end
          click_on(I18n.t("actions.save"))

          existing_vehicle.reload
          expect(existing_vehicle.activities.count).to eq 1
        end
      end
    end

  end
end
