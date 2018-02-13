class CreateCompanyMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :company_members do |t|
      t.references :user
      t.references :company
      t.string :role

      t.timestamps
    end
  end
end
