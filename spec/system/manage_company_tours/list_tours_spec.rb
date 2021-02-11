# frozen_string_literal: true

require "rails_helper"

feature "List Tours", type: :system do
  context "as compnay admin" do
    let(:company_admin) { create(:user, skip_create_driver: true) }
    let(:company) { create(:company) }
    let(:driver) { create(:driver, company: company) }
    let(:existing_tours) { create_list(:tour, number_of_tours, driver: driver) }

    before do
      company.add_member(company_admin, CompanyMember::ADMINISTRATOR)
      sign_in_with(company_admin.email, company_admin.password)
    end

    describe "infinit scroll" do
      let(:number_of_tours) { 40 }

      before { existing_tours }

      it "should load infinitly scroll", js: true  do
        visit(company_tours_path(company))
        existing_tours
        page.find("#content").scroll_to(:bottom)
        sleep(0.5.second)
        expect(page.all('#tours > div').count).to eq number_of_tours
      end

    end

    describe "discarded tours" do
      let(:number_of_tours) { 5 }
      before { existing_tours.first.discard }

      it "will not show removed drives" do
        visit(company_tours_path(company))
        expect(page.all('#tours > div').count).to eq 4
      end
    end
  end
end
