class AddVersionDateToPolicyTerms < ActiveRecord::Migration[5.2]

  def up
    add_column :policy_terms, :version_date, :datetime, index: true, null: false, default: DateTime.current
    if defined?(PolicyTerm)
      # Set the last update time as current version date
      PolicyTerm.find_each { |t| t.update_column(:version_date t.updated_at) }
    end
  end

  def down
    remove_column :policy_terms, :version_date
  end
end
