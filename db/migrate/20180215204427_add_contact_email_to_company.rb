class AddContactEmailToCompany < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :contact_email, :string, null: false
  end
end
