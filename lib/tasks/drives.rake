namespace :drives do
  desc "Creates a couple of hundred demo drives for a demo company"
  task create_demo_drives: :environment do
    from_date = Date.new(2017, 10, 1)
    to_date = Date.new(2018, 04, 29)

    company = Company.first
    driver1 = Driver.find_or_create_by!(name: 'Hans Müller', company: company)
    driver2 = Driver.find_or_create_by!(name: 'Peter Meier', company: company)
    driver3 = Driver.find_or_create_by!(name: 'Fritz Baumann', company: company)
    driver4 = Driver.find_or_create_by!(name: 'Nicolas Reiter', company: company)
    driver5 = Driver.find_or_create_by!(name: 'Ferdinand Stocker', company: company)
    driver6 = Driver.find_or_create_by!(name: 'Kurt Frankhauser', company: company)
    driver7 = Driver.find_or_create_by!(name: 'Sven Dachauer', company: company)
    drivers = [driver1, driver2, driver3, driver4, driver5, driver6, driver7]

    (from_date..to_date).each do |date|
      num_drives = rand(0..6)
      num_drives.times do |num|
        start_time = date.beginning_of_day + num.hours + rand(50..360).minutes
        Drive.create!(start: start_time, end: start_time + rand(15..50).minutes, driver: drivers.sample)
      end
    end


  end

end
