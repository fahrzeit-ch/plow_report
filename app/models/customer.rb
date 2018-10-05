class Customer < ApplicationRecord
  belongs_to :client_of, foreign_key: :company_id, dependent: :delete, class_name: 'Company'

  validates_presence_of :name
end
