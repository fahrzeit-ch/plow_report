class AddCustomerToToursReport < ActiveRecord::Migration[5.2]
  def change
    add_reference :tours_reports, :customer, foreign_key: true
  end
end
