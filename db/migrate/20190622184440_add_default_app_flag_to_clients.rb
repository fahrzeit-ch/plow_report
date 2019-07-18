class AddDefaultAppFlagToClients < ActiveRecord::Migration[5.1]
  def change
    add_column :oauth_applications, :default_app, :boolean, default: false
  end
end
