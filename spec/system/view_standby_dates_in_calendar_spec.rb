# frozen_string_literal: true

require "rails_helper"

feature "view standby dates in calendar" do
  let(:user) { create(:user) }
  let(:driver) { user.drivers.first }

  before do
    user.create_personal_driver
    sign_in_with(user.email, user.password)

    # assume we are in winter season 2018/2019
    travel_to Time.zone.local(2018, 11, 23, 12, 14)

    # we have some standby dates in this season and in the previous one
    create(:standby_date, driver: driver, day: Date.new(2018, 11, 15))
    create(:standby_date, driver: driver, day: Date.new(2017, 11, 15))
  end

  after do
    travel_back
  end

  it "shows the calendar of the current month including existing standby date" do
    visit "/standby_dates"
    expect(page).to have_content("November 2018")
    within(".simple-calendar") do
      expect(page).to have_content(I18n.t("standby_dates.index.standby_label"))
    end
  end

  it "switches to the last standby date of the selected season" do
    visit "/standby_dates?season=2017_2018"
    expect(page).to have_content("November 2017")
    within(".simple-calendar") do
      expect(page).to have_content(I18n.t("standby_dates.index.standby_label"))
    end
  end

  context "navigation outside selected_season" do
    it "shows standby dates of other seasons as well" do
      visit "/standby_dates"
      expect(page).to have_content("November 2018")
      12.times do
        click_link("\u00AB")
      end
      expect(page).to have_content("November 2017")
      within(".simple-calendar") do
        expect(page).to have_content(I18n.t("standby_dates.index.standby_label"))
      end
    end
  end
end
