class AddSiteReferenceToDrive < ActiveRecord::Migration[5.1]
  def change
    add_reference :drives, :site, foreign_key: true
  end
end
