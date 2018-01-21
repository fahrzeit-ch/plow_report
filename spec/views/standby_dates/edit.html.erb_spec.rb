require 'rails_helper'

RSpec.describe "standby_dates/edit", type: :view do
  before(:each) do
    @standby_date = assign(:standby_date, StandbyDate.create!())
  end

  it "renders the edit standby_date form" do
    render

    assert_select "form[action=?][method=?]", standby_date_path(@standby_date), "post" do
    end
  end
end
