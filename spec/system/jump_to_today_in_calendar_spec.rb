# frozen_string_literal: true

require "rails_helper"

feature "jump to today in calendar" do
  let(:user) { create(:user) }
  let(:driver) { user.drivers.first }

  before do
    user.create_personal_driver
    sign_in_with(user.email, user.password)

    # assume we are in winter season 2018/2019
    travel_to Time.zone.local(2018, 11, 23, 12, 14)
  end

  after do
    travel_back
  end

  it "jumps to the current month" do
    visit "/standby_dates"
    expect(page).to have_content("November 2018")

    click_link("\u00AB")
    expect(page).to have_content("Oktober 2018")
    click_link(I18n.t "simple_calendar.jump_to_today")
    expect(page).to have_content("November 2018")
  end
end
