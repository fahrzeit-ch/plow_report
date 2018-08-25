class CreateUserActions < ActiveRecord::Migration[5.1]
  def change
    create_table :user_actions do |t|
      t.string :activity
      t.references :user, foreign_key: true
      t.references :target, polymorphic: true

      t.timestamps
    end
  end
end
