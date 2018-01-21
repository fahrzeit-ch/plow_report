require 'rails_helper'

RSpec.describe "StandbyDates", type: :request do
  describe "GET /standby_dates" do
    it "works! (now write some real specs)" do
      get standby_dates_path
      expect(response).to have_http_status(200)
    end
  end
end
