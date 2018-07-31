class CreateTermAcceptances < ActiveRecord::Migration[5.1]
  def change
    create_table :term_acceptances do |t|
      t.references :user, foreign_key: true
      t.references :policy_term, foreign_key: true
      t.integer :term_version

      t.timestamps
    end
  end
end
