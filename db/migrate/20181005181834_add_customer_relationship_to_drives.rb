class AddCustomerRelationshipToDrives < ActiveRecord::Migration[5.1]
  def change
    add_reference :drives, :customer, foreign_key: true
  end
end
