class MigrateDriveOptions < ActiveRecord::Migration[5.1]

  def self.up
    plow_id = Activity.find_or_create_by name: 'Räumen' do |a|
      a.has_value = false
    end
    salting_id = Activity.find_or_create_by name: 'Salzen' do |a|
      a.has_value = false
    end
    refill_id = Activity.find_or_create_by name: 'Salz füllen' do |a|
      a.has_value = true
      a.value_label = 'Salzmenge'
    end

    Company.all.each do |c|
      plow = c.activities.find_or_create_by name: 'Räumen' do |a|
        a.has_value = false
      end
      salt = c.activities.find_or_create_by name: 'Salzen' do |a|
        a.has_value = false
      end
      refill = c.activities.find_or_create_by name: 'Salz füllen' do |a|
        a.has_value = true
        a.value_label = 'Salzmenge'
      end

      c.drives.each do |drive|
        if drive.salt_refilled
          values = {activity_id: refill.id, value: drive.salt_amount_tonns }
        elsif drive.plowed
          values = {activity_id: plow.id }
        elsif drive.salted
          values = {activity_id: salt.id }
        end
        drive.update(activity_execution_attributes: values) unless values.blank?
      end
    end

    Drive.joins(:driver).where(drivers: {company_id: nil}).find_each do |drive|

      if drive.salt_refilled
        values = {activity_id: refill_id, value: drive.salt_amount_tonns }
      elsif drive.plowed
        values = {activity_id: plow_id }
      elsif drive.salted
        values = {activity_id: salting_id }
      end
      drive.update(activity_execution_attributes: values) unless values.blank?
    end
  end

  def self.down
  end
end
