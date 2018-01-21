require 'rails_helper'

RSpec.describe "drives/edit", type: :view do
  before(:each) do
    @drive = assign(:drive, Drive.create!(
      :distance_km => 1.5,
      :salt_refilled => false,
      :salt_amount_tonns => 1.5,
      :salted => false,
      :plowed => false
    ))
  end

  it "renders the edit drive form" do
    render

    assert_select "form[action=?][method=?]", drive_path(@drive), "post" do

      assert_select "input[name=?]", "drive[distance_km]"

      assert_select "input[name=?]", "drive[salt_refilled]"

      assert_select "input[name=?]", "drive[salt_amount_tonns]"

      assert_select "input[name=?]", "drive[salted]"

      assert_select "input[name=?]", "drive[plowed]"
    end
  end
end
