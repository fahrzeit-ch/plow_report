require 'rails_helper'

RSpec.describe "drives/show", type: :view do
  before(:each) do
    @drive = assign(:drive, Drive.create!(
      :distance_km => 2.5,
      :salt_refilled => false,
      :salt_amount_tonns => 3.5,
      :salted => false,
      :plowed => false
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2.5/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/3.5/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
  end
end
