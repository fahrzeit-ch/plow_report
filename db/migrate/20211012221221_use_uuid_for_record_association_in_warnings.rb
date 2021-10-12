class UseUuidForRecordAssociationInWarnings < ActiveRecord::Migration[6.1]
  def change
    remove_column :reasonability_check_warnings, :record_id
    remove_column :reasonability_check_warnings, :record_type
    add_reference :reasonability_check_warnings, :record, polymorphic: true, type: :uuid, index: true
  end
end
