require 'rails_helper'

RSpec.describe "drives/new", type: :view do
  before(:each) do
    assign(:drive, Drive.new(
      :distance_km => 1.5,
      :salt_refilled => false,
      :salt_amount_tonns => 1.5,
      :salted => false,
      :plowed => false
    ))
  end

  it "renders new drive form" do
    render

    assert_select "form[action=?][method=?]", drives_path, "post" do

      assert_select "input[name=?]", "drive[distance_km]"

      assert_select "input[name=?]", "drive[salt_refilled]"

      assert_select "input[name=?]", "drive[salt_amount_tonns]"

      assert_select "input[name=?]", "drive[salted]"

      assert_select "input[name=?]", "drive[plowed]"
    end
  end
end
