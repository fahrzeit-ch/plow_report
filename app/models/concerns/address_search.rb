module AddressSearch
  extend ActiveSupport::Concern

  included do
    def self.search(q)
      if q.blank?
        self.all
      else
        where("name || ' ' || first_name || ' ' || street || ' ' || city ILIKE ?", "%#{q}%")
      end
    end
  end
end

