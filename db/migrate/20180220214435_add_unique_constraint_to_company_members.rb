class AddUniqueConstraintToCompanyMembers < ActiveRecord::Migration[5.1]
  def change
    add_index :company_members, [:user_id, :company_id], unique: true
  end
end
