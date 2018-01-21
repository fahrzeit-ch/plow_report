require 'rails_helper'

RSpec.describe "standby_dates/new", type: :view do
  before(:each) do
    assign(:standby_date, StandbyDate.new())
  end

  it "renders new standby_date form" do
    render

    assert_select "form[action=?][method=?]", standby_dates_path, "post" do
    end
  end
end
