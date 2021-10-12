class CreateReasonabilityCheckWarnings < ActiveRecord::Migration[6.1]
  def change
    create_table :reasonability_check_warnings do |t|
      t.references :record, polymorphic: true, null: false
      t.json :warnings

      t.timestamps
    end
  end
end
