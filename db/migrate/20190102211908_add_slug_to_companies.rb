# frozen_string_literal: true

# class Company < ActiveRecord::Base; end # In case the company model was dropped this prevents the migration from failing.

class AddSlugToCompanies < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :slug, :string
    Company.find_each { |company| company.create_slug; company.save! }
    add_index :companies, :slug, unique: true
  end
end
