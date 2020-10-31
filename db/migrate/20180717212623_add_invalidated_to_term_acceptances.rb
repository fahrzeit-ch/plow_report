# frozen_string_literal: true

class AddInvalidatedToTermAcceptances < ActiveRecord::Migration[5.1]
  def change
    add_column :term_acceptances, :invalidated_at, :datetime
  end
end
