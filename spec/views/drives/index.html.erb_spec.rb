require 'rails_helper'

RSpec.describe "drives/index", type: :view do
  before(:each) do
    assign(:drives, [
      Drive.create!(
        :distance_km => 2.5,
        :salt_refilled => false,
        :salt_amount_tonns => 3.5,
        :salted => false,
        :plowed => false
      ),
      Drive.create!(
        :distance_km => 2.5,
        :salt_refilled => false,
        :salt_amount_tonns => 3.5,
        :salted => false,
        :plowed => false
      )
    ])
  end

  it "renders a list of drives" do
    render
    assert_select "tr>td", :text => 2.5.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => 3.5.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
