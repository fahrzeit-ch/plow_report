class CreateActivities < ActiveRecord::Migration[5.1]
  def change
    create_table :activities do |t|
      t.references :company, foreign_key: true, null: true
      t.string :name, default: '', null: false
      t.boolean :has_value, default: true, null: false
      t.string :value_label
    end
    add_index :activities, :name
    add_index :activities, [:company_id, :name], unique: true
  end
end
