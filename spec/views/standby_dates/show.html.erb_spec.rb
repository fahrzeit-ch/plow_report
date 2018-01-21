require 'rails_helper'

RSpec.describe "standby_dates/show", type: :view do
  before(:each) do
    @standby_date = assign(:standby_date, StandbyDate.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
