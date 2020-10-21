class CreateDriverApplications < ActiveRecord::Migration[5.1]
  def change
    create_table :driver_applications do |t|
      t.references :user, foreign_key: true
      t.string :recipient, null: false
      t.string :token, index: true, null: false, unique: true
      t.references :accepted_by, foreign_key: {to_table: :users}
      t.references :accepted_to, foreign_key: {to_table: :companies}
      t.datetime :accepted_at
      t.timestamps
    end
  end
end
