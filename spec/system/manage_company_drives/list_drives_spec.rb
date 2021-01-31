# frozen_string_literal: true

require "rails_helper"

feature "List Drives", type: :system do
  context "as compnay admin" do
    let(:company_admin) { create(:user, skip_create_driver: true) }
    let(:company) { create(:company) }
    let(:driver) { create(:driver, company: company) }
    let(:existing_drives) { create_list(:drive, number_of_drives, driver: driver, start: 1.hour.ago, end: (1.hour.ago + 2.minute)) }

    before do
      company.add_member(company_admin, CompanyMember::ADMINISTRATOR)
      sign_in_with(company_admin.email, company_admin.password)
    end

    describe "stats" do
      let(:number_of_drives) { 5 }
      before { existing_drives.first.discard }
      it "displays total duration without discarded values" do
        visit(company_drives_path(company))
        expect(page).to have_content(I18n.t('views.stats.duration'))
        expect(page).to have_content("8min")
      end
    end

    describe "infinit scroll" do
      let(:number_of_drives) { 40 }

      before { existing_drives }

      it "should load infinitly scroll", js: true  do
        visit(company_drives_path(company))
        existing_drives
        page.find("#content").scroll_to(:bottom)
        sleep(0.5.second)
        expect(page.all('#drives > div.item-group').count).to eq number_of_drives
      end

    end

    describe "discarded drives" do
      let(:number_of_drives) { 5 }
      before { existing_drives.first.discard }

      it "will not show removed drives" do
        visit(company_drives_path(company))
        expect(page.all('#drives > div.item-group').count).to eq 4
      end
    end
  end
end
