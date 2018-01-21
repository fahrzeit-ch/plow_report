require 'rails_helper'

RSpec.describe "standby_dates/index", type: :view do
  before(:each) do
    assign(:standby_dates, [
      StandbyDate.create!(),
      StandbyDate.create!()
    ])
  end

  it "renders a list of standby_dates" do
    render
  end
end
