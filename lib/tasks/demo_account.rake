# frozen_string_literal: true

namespace :demo_account do
  desc "Creates a demo company with a basic setup"
  task create_company: :environment do
    Audited.auditing_enabled = false
    Company.transaction do
      company = Company.find_or_create_by(name: ENV["DEMO_ACCOUNT_COMPANY_NAME"]) do |c|
        c.contact_email = "info@fahrzeit.ch"
        c.address = "Filibachstrasse"
        c.nr = "13"
        c.zip_code = "8394"
        c.city = "Bielsdorf"
      end

      company.activities.find_or_create_by(name: "Räumen") do |a|
        a.has_value = false
        a.company = company
      end
      company.activities.find_or_create_by(name: "Räumen Unimog") do |a|
        a.has_value = false
        a.company = company
      end
      company.activities.find_or_create_by(name: "Räumen Hand") do |a|
        a.has_value = false
        a.company = company
      end
      company.activities.find_or_create_by(name: "Salzen") do |a|
        a.has_value = true
        a.value_label = "Salzmenge (kg)"
        a.company = company
      end

      user = User.create!(name: "Demo User", email: ENV["DEMO_ACCOUNT_EMAIL"], password: ENV["DEMO_ACCOUNT_PASSWORD"], password_confirmation: ENV["DEMO_ACCOUNT_PASSWORD"], skip_create_driver: true)
      company.company_members.create(user: user, role: CompanyMember::DEMO_ACCOUNT)

      ActiveRecord::Base.connection.execute(build_customer_query(company.id))
      ActiveRecord::Base.connection.execute(build_sites_insert_query(company.id))

      Driver.find_or_create_by!(name: "Fritz Baumann", company: company)
      Driver.find_or_create_by!(name: "Nicolas Reiter", company: company)
      Driver.find_or_create_by!(name: "Ferdinand Stocker", company: company)
      Driver.find_or_create_by!(name: "Kurt Frankhauser", company: company)
      Driver.find_or_create_by!(name: "Sven Dachauer", company: company)
      create_sample_tours company
    end
    Audited.auditing_enabled = false
  end

  desc "Reset demo company"
  task reset: :environment do
    Audited.auditing_enabled = false
    ActiveRecord::Base.transaction do
      company = Company.find_by(name: ENV["DEMO_ACCOUNT_COMPANY_NAME"])
      Drive.unscoped.joins(:driver).where({ drivers: { company_id: company.id } }).destroy_all
      company.tours.with_discarded.delete_all
      StandbyDate.unscoped.joins(:driver).where({ drivers: { company_id: company.id } }).destroy_all
      create_sample_tours company
      create_sample_standby_dates company
    end
    Audited.auditing_enabled = true
  end

  def create_sample_standby_dates(company)
    from_date = Date.today
    drivers = company.drivers.all.to_a
    to_date = from_date + 1.month
    counter = 0
    driver = drivers.sample
    (from_date..to_date).each do |date|
      counter += 1
      if counter > 5
        driver = drivers.sample
        counter = 0
      end
      StandbyDate.create(driver: driver, day: date)
    end
  end

  def create_sample_tours(company)
    drivers = company.drivers.to_a
    customer_sites = Site.joins(:customer).where({ customers: { company_id: company.id } }).all.to_a
    activities = company.activities.all.to_a

    from_date = 3.months.ago.to_date
    to_date = 1.day.ago.to_date

    (from_date..to_date).each do |date|
      num_drives = rand(3..6)
      driver = drivers.sample
      tour = Tour.create(start_time: date.beginning_of_day + rand(6..15).hours + rand(0..360).minutes, driver: driver)
      last_end_time = tour.start_time
      activity = activities.sample
      num_drives.times do
        customer_site = customer_sites.sample
        start_time = last_end_time + rand(0..10).minutes
        end_time = start_time + rand(15..50).minutes

        activity_value = activity.has_value? ? rand(0.5..4).round(1) : 0
        km = activity.name == "Räumen Hand" ? 0.0 : rand(1.5..12).round(1)

        Drive.create!(start: start_time, distance_km: km, end: end_time, driver: driver, tour: tour, customer: customer_site.customer, site: customer_site, activity_execution_attributes: { activity_id: activity.id, value: activity_value })
        last_end_time = end_time
      end
      tour.update_attribute(:end_time, last_end_time + rand(2..10).minutes)
    end
  end

  def build_customer_query(company_id)
    <<SQL
INSERT INTO public.customers ("name",company_id,created_at,updated_at,street,nr,zip,city,first_name) VALUES #{}
('Gasser',#{company_id},'2020-05-21 16:17:05.876','2020-05-21 16:17:05.876','Bachmattweg','','7270','Davos','Tanja')
,('Imholz',#{company_id},'2020-05-21 16:17:50.196','2020-05-21 16:17:50.196','Feusisbergli','12','7270','Davos','Sara')
,('Schlegel',#{company_id},'2019-04-22 12:17:37.139','2019-04-22 12:17:37.139','','','','','Rolf')
,('Moor',#{company_id},'2020-05-21 16:18:46.878','2020-05-21 16:18:46.878','Dreispitz','3','7270','Davos','Martina')
,('Streich',#{company_id},'2020-05-21 16:19:31.634','2020-05-21 16:19:31.634','Bergweg','65','7270','Davos','Petra')
,('Zeller',#{company_id},'2019-04-22 11:55:44.238','2020-05-21 09:24:56.666','Spitzenmatte','3','8816','Hirzel','David')
,('Abächerli',#{company_id},'2020-05-21 16:20:23.285','2020-05-21 16:20:23.285','Neugasse','19','7075','Churwalden','Sonja')
,('Gobbi',#{company_id},'2019-04-22 11:46:50.990','2020-05-21 09:38:59.972','Sonnweg','3','5746','Walterswil','Simon')
,('Däscher',#{company_id},'2019-04-22 11:47:55.260','2020-05-21 09:46:03.851','Spitalstrasse','12','6113','Romoos','Karin')
,('Escher',#{company_id},'2020-05-21 15:46:01.430','2020-05-21 15:46:01.430','Bettingerweg','2','6113','Romoos','Erika')
,('Arnold',#{company_id},'2020-05-21 15:52:14.241','2020-05-21 15:52:14.241','Akazienweg','17','6113','Rosmoos','Rolf')
,('Immobilien Engelberg',#{company_id},'2020-05-21 15:56:38.585','2020-05-21 15:56:38.585','Haldenstrasse','3','6390','Engelberg','z.H. Jordan Beatrice')
,('Bosshard',#{company_id},'2020-05-21 16:01:40.502','2020-05-21 16:01:40.502','Rösligasse','14','6467','Schattdorf','Jürg')
,('Schmid',#{company_id},'2020-05-21 16:02:11.224','2020-05-21 16:02:11.224','Sternenplatz','6','6467','Schattdorf','Roger')
,('Caratsch',#{company_id},'2020-05-21 16:04:20.566','2020-05-21 16:04:20.566','Seewenstrasse','168','8887','Mels','Daniel')
,('Bonzani',#{company_id},'2020-05-21 16:04:47.643','2020-05-21 16:04:47.643','Albulastrasse','5','8887','Mels','Brigitta')
,('Hässig',#{company_id},'2020-05-21 16:05:25.331','2020-05-21 16:05:25.331','Blauäcker','12','8887','Mels','Gabriela')
,('Marti',#{company_id},'2020-05-21 16:05:52.051','2020-05-21 16:05:52.051','Eigenstrasse','3','8887','Mels','José')
,('Zimmermann',#{company_id},'2020-05-21 16:07:05.391','2020-05-21 16:07:05.391','Eisgasse','1','9200','Gossau','Christoph')
,('Bissig',#{company_id},'2020-05-21 16:16:25.776','2020-05-21 16:16:25.776','Austrasse','19','7270','Davos','Pascal')
,('Gemeinde Churwalden',#{company_id},'2020-05-21 16:22:59.982','2020-05-21 16:22:59.982','Werkgasse','70','7075','Churwalden','z.H. Kälin Florian')
,('Ochsner',#{company_id},'2020-05-21 16:30:34.129','2020-05-21 16:30:34.129','Hausmattweg','5','1973','Nax','Kevin')
,('Marty',#{company_id},'2020-05-21 16:31:32.276','2020-05-21 16:31:32.276','Herrengasse','3','1973','Nax','Daniela')
,('Betschart',#{company_id},'2020-05-21 16:32:15.148','2020-05-21 16:32:15.148','Höhenweg','17','1973','Nax','Melanie')
,('Schnüriger',#{company_id},'2020-05-21 16:32:55.560','2020-05-21 16:32:55.560','Blumenweg','18','1973','Nax','Fabienne')
,('Suter',#{company_id},'2020-05-21 16:33:34.302','2020-05-21 16:33:34.302','Brand','','1973','Nax','Nadine')
,('Bieri',#{company_id},'2020-05-21 16:34:33.836','2020-05-21 16:34:33.836','Fuchsmatte','1','1950','Sion','Jasmin')
,('Waber',#{company_id},'2020-05-21 16:37:34.584','2020-05-21 16:37:34.584','Weid','3','1680','Romont','Lisa')
,('Rutz',#{company_id},'2020-05-21 16:45:06.597','2020-05-21 16:45:06.597','Ottstrasse','37','4222','Zwingen','Levin')
,('Bühler',#{company_id},'2020-05-21 16:45:54.243','2020-05-21 16:45:54.243','Plantaweg','3','4222','Zwingen','Emma')
,('Lustenberger',#{company_id},'2020-05-21 16:46:49.086','2020-05-21 16:46:49.086','Industriestrasse','153','4222','Zwingen','Elena')
,('Bucher',#{company_id},'2020-05-21 16:47:37.256','2020-05-21 16:47:37.256','Hofgraben','2','4222','Zwingen','Lea')
,('Fischer',#{company_id},'2020-05-21 16:48:40.116','2020-05-21 16:48:40.116','Holunderweg','9','8418','Schlatt','Mia')
,('Bardill',#{company_id},'2020-05-21 16:49:16.107','2020-05-21 16:49:16.107','Rabengasse','7','8418','Schlatt','Alina')
,('Gyger',#{company_id},'2020-05-21 16:49:56.956','2020-05-21 16:49:56.956','Tödistrasse','12','8418','Schlatt','Aron')
,('Bichsel',#{company_id},'2020-05-21 16:52:40.513','2020-05-21 16:52:40.513','Sennhostrasse','13','8824','Schönenberg','Ben')
,('Baumgartner',#{company_id},'2020-05-21 16:53:13.702','2020-05-21 16:53:13.702','Spechtweg','7','8824','Schönenberg','Diego')
,('Portier',#{company_id},'2020-05-21 16:54:06.162','2020-05-21 16:54:06.162','Ringstrasse','1','8824','Schönenberg','Leo')
,('Stettler',#{company_id},'2020-05-21 15:59:44.526','2020-09-16 14:19:23.193','Pilatusweg','3','6437','Schattdorf','Rudolf')
;
SQL
  end

  def build_sites_insert_query(company_id)
    <<SQL
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Bissig','Austrasse','19','7270','Davos Platz',id,TRUE,'2020-05-21 16:16','2020-09-16 12:51','Vorplatz Bissig','Pascal','{"type":"Point","coordinates":[9.818753663253895,46.792312959661515]}'from customers where company_id=#{company_id} and name ='Bissig'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Hösli','Rieterplatz','47','7075','Churwalden',id,TRUE,'2020-05-21 16:21','2020-09-07 15:50','Treppe','Benjamin','{"type":"Point","coordinates":[8.714101860286458,47.20166263178428]}'from customers where company_id=#{company_id} and name ='Abächerli'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Wildi','Heuberg','7','6113','Romoos',id,TRUE,'2019-04-22 11:48','2020-09-16 13:1','Restaurant Rössli','Marianne','{"type":"Point","coordinates":[8.015999944792798,46.99840170553912]}'from customers where company_id=#{company_id} and name ='Däscher'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Hefti','Luegete','69','7035','Churwalden',id,TRUE,'2020-05-21 16:22','2020-09-16 12:37','Parkplatz','Nicolas','{"type":"Point","coordinates":[9.541797436410938,46.78116989279387]}'from customers where company_id=#{company_id} and name ='Abächerli'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Escher','Bettingerweg','2','6113','Romoos',id,TRUE,'2020-05-21 15:49','2020-09-16 13:3','Bettingerweg','Erika','{"type":"LineString","coordinates":[[8.02077337612704,47.00616468114383],[8.020472968717373,47.00568912574677],[8.019872153898037,47.00578423716485],[8.019582475324428,47.00604762174658]]}'from customers where company_id=#{company_id} and name ='Escher'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Gasser','Bachmattweg','','7270','Davos',id,TRUE,'2020-05-21 16:17','2020-09-16 13:6','Gasser','Tanja','{"type":"Point","coordinates":[9.835965279083787,46.807063935776384]}'from customers where company_id=#{company_id} and name ='Gasser'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Gianni','Pelikanweg','11','5746','Walterswil',id,TRUE,'2019-04-22 11:47','2020-09-16 13:16','Tiefgarageneinfahrt Pelikanweg','Andrea','{"type":"Point","coordinates":[7.960548653946304,47.32439456078624]}'from customers where company_id=#{company_id} and name ='Gobbi'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Conrad','Hochstrasse','45','6113','Romoos',id,TRUE,'2019-04-22 11:48','2020-09-16 13:27','Metzgerei Conrad','Laura','{"type":"Point","coordinates":[8.012812730150749,47.00130694816715]}'from customers where company_id=#{company_id} and name ='Däscher'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Entsorgungsstelle','Ehrlistrasse','79','7075','Churwalden',id,TRUE,'2020-05-21 16:23','2020-09-16 13:29','Entsorgungsstelle','','{"type":"Point","coordinates":[9.541831443341131,46.77684213461784]}'from customers where company_id=#{company_id} and name ='Gemeinde Churwalden'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Imholz','Feusisbergli','12','7270','Davos',id,TRUE,'2020-05-21 16:18','2020-09-16 13:36','Feusisbergli','Sara','{"type":"Point","coordinates":[9.84763829366968,46.80458294615501]}'from customers where company_id=#{company_id} and name ='Imholz'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Marugg','Löwengraben','6','6390','Engelberg',id,TRUE,'2020-05-21 15:58','2020-09-16 13:39','Parkplatz Löwengraben','Susanne','{"type":"Point","coordinates":[8.403714949084309,46.819581229849256]}'from customers where company_id=#{company_id} and name ='Immobilien Engelberg'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Restaurant Zentral','Zentralstrasse','7','6390','Engelberg',id,TRUE,'2020-05-21 15:58','2020-09-16 13:40','Restaurant Zentral','Casutt Bernadette','{"type":"Point","coordinates":[8.402962748895693,46.81899369812041]}'from customers where company_id=#{company_id} and name ='Immobilien Engelberg'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Ochsner','Hausmattweg','5','1973','Nax',id,TRUE,'2020-05-21 16:30','2020-09-16 14:8','Hausmattweg','Kevin','{"type":"LineString","coordinates":[[7.427044539335714,46.22733414570463],[7.427344946745382,46.226684699754]]}'from customers where company_id=#{company_id} and name ='Ochsner'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Streich','Bergweg','65','7270','Davos',id,TRUE,'2020-05-21 16:19','2020-09-16 14:21','Wendeplatz','Petra','{"type":"Point","coordinates":[9.815016859443192,46.80124994452412]}'from customers where company_id=#{company_id} and name ='Streich'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Hämmerli','Oberkirchstrasse','2','9604','Lüthisburg',id,TRUE,'2019-04-22 11:56','2020-09-16 14:30','Hämmerli','Marcel','{"type":"Point","coordinates":[9.082313859920278,47.39577886944709]}'from customers where company_id=#{company_id} and name ='Zeller'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Rhyner','Ziegelstrasse','17','8856','Walterswil',id,TRUE,'2019-04-22 11:56','2020-09-16 14:30','Sanitär AG','Roland','{"type":"Point","coordinates":[7.961298251286744,47.32324834670514]}'from customers where company_id=#{company_id} and name ='Zeller'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Schmäh','Florastrasse','18','9200','Gossau',id,TRUE,'2020-05-21 16:11','2020-09-16 14:32','Floastrasse','Reto','{"type":"LineString","coordinates":[[9.239701380944657,47.41806786064132],[9.238574853158402,47.41833646517596],[9.237834563470292,47.416993428799955]]}'from customers where company_id=#{company_id} and name ='Zimmermann'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Zimmermann','Eisgasse','1','9200','Gossau',id,TRUE,'2020-05-21 16:7','2020-09-16 14:33','Eisgasse','Christoph','{"type":"Point","coordinates":[9.247973229925757,47.41527047838543]}'from customers where company_id=#{company_id} and name ='Zimmermann'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Zweifel','Buchholzstrasse','13','9200','Gossau',id,TRUE,'2020-05-21 16:10','2020-09-16 14:33','Garageneinfahrt Zweifel','Marc','{"type":"Point","coordinates":[9.24909282771979,47.415602931410646]}'from customers where company_id=#{company_id} and name ='Zimmermann'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Enz','Nietengasse','45','7075','Churwalden',id,TRUE,'2020-05-21 16:20','2020-09-07 15:52','Hauszugang','Fabian','{"type":"Point","coordinates":[8.716711118968416,47.20074791119151]}'from customers where company_id=#{company_id} and name ='Abächerli'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Abächerli','Neugasse','19','7075','Churwalden',id,TRUE,'2020-05-21 16:20','2020-09-16 12:40','Neugasse','Sonja','{"type":"LineString","coordinates":[[9.543577553770417,46.78009292951754],[9.543046476385468,46.78004517327755],[9.542536856672639,46.77975863494815],[9.542542221090669,46.77957128213904]]}'from customers where company_id=#{company_id} and name ='Abächerli'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Bardill','Rabengasse','7','8418','Schlatt',id,TRUE,'2020-05-21 16:49','2020-09-16 12:46','Rabengasse','Alina','{"type":"LineString","coordinates":[[8.827139527925967,47.468558143464456],[8.827493579515933,47.46905857298557],[8.828394888858012,47.46971452425581],[8.827836989382915,47.46938816179041],[8.828094481448344,47.46917783823888],[8.827858447055034,47.46898927158059],[8.827397107104472,47.469076302430025]]}'from customers where company_id=#{company_id} and name ='Bardill'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Betschart','Höhenweg','17','1973','Nax',id,TRUE,'2020-05-21 16:32','2020-09-16 12:47','Höhenweg','Melanie','{"type":"LineString","coordinates":[[7.4267273274514345,46.229560580545034],[7.427714380368915,46.23010979798862],[7.428744348630634,46.23129727637696],[7.430224928006854,46.231401179513576],[7.432864221677509,46.23224724058966],[7.433100256070819,46.232024594202564],[7.431211980924335,46.23019885975893],[7.4296241131875185,46.22960511189386],[7.4296241131875185,46.22936761094938],[7.428701433286395,46.22907073332366],[7.426984819516864,46.228773854092225],[7.426684412107196,46.229441830104925]]}'from customers where company_id=#{company_id} and name ='Betschart'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Bieri','Fuchsmatte','1','1950','Sitten',id,TRUE,'2020-05-21 16:34','2020-09-16 12:49','MFH Fuchsmatte','Jasmin','{"type":"Point","coordinates":[7.35890642800014,46.232386288283585]}'from customers where company_id=#{company_id} and name ='Bieri'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Baumgartner','Spechtweg','7','8824','Schönenberg',id,TRUE,'2020-05-21 16:53','2020-09-07 15:58','Umfahrung','Diego','{"type":"Point","coordinates":[8.643587918304426,47.193397298251156]}'from customers where company_id=#{company_id} and name ='Baumgartner'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Bichsel','Sennhostrasse','13','8824','Schönenberg',id,TRUE,'2020-05-21 16:52','2020-09-07 16:0','Bichsel','Ben','{"type":"Point","coordinates":[8.637119774212056,47.194017389123005]}'from customers where company_id=#{company_id} and name ='Bichsel'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Krummenacher','Wiesenweg','34','1950','Sitten',id,TRUE,'2020-05-21 16:35','2020-09-16 12:49','Wiesenweg','Jan','{"type":"LineString","coordinates":[[7.378129751235409,46.228674113034415],[7.3781512089075285,46.22880028713326],[7.3784516163171965,46.22889120652468],[7.37923213914053,46.22932167996609],[7.379414529353543,46.229273437420794],[7.379419893771573,46.2291361314829],[7.37899074032919,46.22890233950107],[7.378454298526211,46.228868940565214]]}'from customers where company_id=#{company_id} and name ='Bieri'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Zemp','Büelweg','23','1950','Sion',id,TRUE,'2020-05-21 16:35','2020-09-07 16:2','Büelweg','Samuel','{"type":"LineString","coordinates":[[7.356747175939988,46.23476505943058],[7.355749394186448,46.2357446478603],[7.355416800268602,46.235737226801575],[7.3547945277771465,46.2350544851048],[7.352841879614305,46.23417878223336]]}'from customers where company_id=#{company_id} and name ='Bieri'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Fischer','Holunderweg','9','8418','Schlatt',id,TRUE,'2020-05-21 16:48','2020-09-16 13:5','Holunderweg','Mia','{"type":"LineString","coordinates":[[8.82210993691701,47.46739324330464],[8.822303055966083,47.46777038739678],[8.821959733212177,47.46826357174178],[8.8228824131133,47.469278936704285],[8.82313990517873,47.46933695696681],[8.82337593957204,47.46923542146533],[8.82339739724416,47.468423130392054],[8.824234246456806,47.46772687090889],[8.824706315243427,47.46784291479657],[8.825500249111835,47.46750928792892],[8.8238909237029,47.46730620966831],[8.823054074490253,47.467436760068765],[8.82210993691701,47.46736423210854],[8.820564984524433,47.46749478236489]]}'from customers where company_id=#{company_id} and name ='Fischer'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Siegenthaler','Zugerstrasse','27','1950','Sion',id,TRUE,'2020-05-21 16:36','2020-09-07 16:3','Zugerstrasse','Dominik','{"type":"LineString","coordinates":[[7.312774640248048,46.22464107448801],[7.322559338734376,46.2249379760716],[7.325477582142579,46.22547239487562],[7.329511624500977,46.22499735619565],[7.344274502918946,46.228085034136924],[7.35440252415918,46.22856004609744],[7.359123212025391,46.228025657352816],[7.367963772938477,46.231410031536505],[7.3744010745742195,46.23924672845523],[7.38291188601282,46.24507354531883]]}'from customers where company_id=#{company_id} and name ='Bieri'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Gerber','Zingelweg','15','1950','Sion',id,TRUE,'2020-05-21 16:36','2020-09-07 16:4','Hauseingang Gerber','Robin','{"type":"Point","coordinates":[7.35604327984186,46.235199029759045]}'from customers where company_id=#{company_id} and name ='Bieri'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Bonzani','Albulastrasse','5','8887','Mels',id,TRUE,'2020-09-07 16:7','2020-09-07 16:8','Bonzani Brigitta','Brigitta','{"type":"Point","coordinates":[9.422245025403742,47.047972936784056]}'from customers where company_id=#{company_id} and name ='Bonzani'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Rhiner','Enzianweg','14','4417','Ziefen',id,TRUE,'2020-05-21 16:43','2020-09-16 13:45','Doppelparkplatz','Leandro','{"type":"Point","coordinates":[7.705105534757051,47.43189109189126]}'from customers where company_id=#{company_id} and name ='Immobilien Engelberg'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Bucher','Hofgraben','2','4222','Zwingen',id,TRUE,'2020-05-21 16:47','2020-09-07 16:12','Bucher','Lea','{"type":"LineString","coordinates":[[7.524801614389478,47.43687830271741],[7.526131990060865,47.43621065387253],[7.526625516519605,47.435238193660595],[7.529093148813306,47.43349642895855]]}'from customers where company_id=#{company_id} and name ='Bucher'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Arnold','Akazienweg','17','6113','Romoos',id,TRUE,'2020-09-03 18:17','2020-09-16 13:22','Arnolad','Rolf','{"type":"Point","coordinates":[8.007686670545041,47.01008621181289]}'from customers where company_id=#{company_id} and name ='Arnold'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Bosshard','Rössligasse','14','6467','Schattdorf',id,TRUE,'2020-09-07 16:9','2020-09-16 13:26','Bosshard Jürg','Jürg','{"type":"Point","coordinates":[8.652995641604647,46.85524245787281]}'from customers where company_id=#{company_id} and name ='Bosshard'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Tinner','Bärenloch','16','4417','Ziefen',id,TRUE,'2020-05-21 16:43','2020-09-16 13:46','Bärenloch','Matteo','{"type":"Point","coordinates":[7.707248080650433,47.430616794872]}'from customers where company_id=#{company_id} and name ='Immobilien Engelberg'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Rutz','Ottstrasse','37','4222','Zwingen',id,TRUE,'2020-05-21 16:45','2020-09-16 14:13','Rutz','Levin','{"type":"Point","coordinates":[7.538543586176973,47.440509415608275]}'from customers where company_id=#{company_id} and name ='Rutz'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Schnüriger','Blumenweg','18','1973','Nax',id,TRUE,'2020-05-21 16:33','2020-09-16 14:18','Blumenweg','Fabienne','{"type":"LineString","coordinates":[[7.4269386716597285,46.22883109698667],[7.426670450758239,46.229636377332774],[7.42785307509362,46.23026907488499],[7.428883043355339,46.23126358689743],[7.43034216505944,46.231456549827335],[7.432917085713737,46.23218386554224],[7.433153120107048,46.231946375756344],[7.431157556599968,46.230150325977704]]}'from customers where company_id=#{company_id} and name ='Schnüriger'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Waber','Weid','3','1680','Romont',id,TRUE,'2020-05-21 16:37','2020-09-16 14:24','Waber','Lisa','{"type":"Point","coordinates":[6.897240470233705,46.670734706028995]}'from customers where company_id=#{company_id} and name ='Waber'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Walser','Tramstrasse','2','1680','Romont',id,TRUE,'2020-05-21 16:38','2020-09-16 14:24','Walser','Fabio','{"type":"Point","coordinates":[6.9117160307064385,46.690432752341884]}'from customers where company_id=#{company_id} and name ='Waber'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Gmür','Casinoplatz','1','1680','Romont',id,TRUE,'2020-05-21 16:38','2020-09-16 14:26','Terrasse Gmür','Nina','{"type":"Point","coordinates":[6.909703265793179,46.69324466208711]}'from customers where company_id=#{company_id} and name ='Waber'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Bühler','Plantaweg','3','4222','Zwingen',id,TRUE,'2020-05-21 16:46','2020-09-07 16:18','Plantaweg','Emma','{"type":"LineString","coordinates":[[7.530792865662654,47.43704566825784],[7.529183540253719,47.437248863404584],[7.528818759827693,47.43710372409411],[7.528690013794979,47.43617482302691],[7.529183540253719,47.4355942515326],[7.530621204285701,47.43489755728402]]}'from customers where company_id=#{company_id} and name ='Bühler'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Caratsch','Seewenstrasse','168','8887','Mels',id,TRUE,'2020-09-16 12:56','2020-09-16 12:57','Seewenstrasse','Daniel','{"type":"LineString","coordinates":[[9.427730916090459,47.046420724321116],[9.428642867155522,47.045601920874944],[9.428106425352544,47.04533873138378],[9.427173016615361,47.046172160317816],[9.428063510008306,47.04535335305622],[9.427580712385625,47.045163271001584],[9.426765320845098,47.045930905912854]]}'from customers where company_id=#{company_id} and name ='Caratsch'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Däscher','Spitalstrasse','12','6113','Romoos',id,TRUE,'2020-09-16 13:0','2020-09-16 13:0','Däscher','Karin','{"type":"LineString","coordinates":[[8.009114861887511,47.00189833717953],[8.009211421412047,47.00180321884278],[8.009222150248107,47.00169346670537],[8.009801507395323,47.001481278600366],[8.010337949198302,47.0014666449069],[8.010938764017638,47.00126177277736],[8.012440801065978,47.001225188385845],[8.012955785196837,47.001239822145465],[8.013588786524352,47.00156908067706],[8.01465094129425,47.001773951628216],[8.015294671457823,47.001993455346906],[8.017068030155112,47.00257147749183],[8.017797591007163,47.00263732771911]]}'from customers where company_id=#{company_id} and name ='Däscher'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Zenklusen','Ackerstrasse','128','6113','Rosmoos',id,TRUE,'2020-05-21 15:50','2020-09-16 13:3','Ackerstrasse','Beat','{"type":"LineString","coordinates":[[8.008176144060801,47.0061432877963],[8.010150249895762,47.00633350884588],[8.010557945666026,47.00623108221104],[8.010493572649668,47.00576284366496],[8.008841331896495,47.004475166500036],[8.009034450945567,47.00422640710677],[8.009291943010997,47.00422640710677],[8.00972109645338,47.00443126786776],[8.010879810747813,47.00463612784312],[8.011673744616221,47.00498731454459],[8.012510593828868,47.004723924734925],[8.013347443041514,47.005221437729595],[8.01444178431959,47.00580674120301],[8.015557583269786,47.00558725315204],[8.016802128252696,47.005645783387145],[8.016887958941172,47.00580674120301],[8.01645880549879,47.006040860796716],[8.016887958941172,47.006787110153624],[8.016973789629649,47.007387028547846],[8.018068130907725,47.00791378060694],[8.018518742022227,47.00767689202279],[8.019548710283946,47.007837843718534],[8.019977863726329,47.007896371487675],[8.02044993251295,47.00769152401517],[8.020664509234141,47.00776468391695]]}'from customers where company_id=#{company_id} and name ='Escher'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Gemeinde Churwalden','Werkgasse','70','7075','Churwalden',id,TRUE,'2020-05-21 16:23','2020-09-16 13:7','Werkhof','z.H. Kälin Florian','{"type":"LineString","coordinates":[[9.53905971460792,46.77801796958063],[9.538732485108103,46.77718036018141],[9.538877324394907,46.77714729638518],[9.539183096222605,46.77797021150025],[9.539344028763498,46.777915105970244],[9.53903289251777,46.77710688505111],[9.539231375984873,46.777040757348125],[9.539510325722421,46.77787836891889],[9.539832190804209,46.77782326329492],[9.539515690140451,46.77699667216766],[9.53981609755012,46.77694891318146],[9.54006286077949,46.7777571364717],[9.54005749636146,46.777650598641216],[9.54027743750068,46.777628556305146],[9.540111140541757,46.77691584924312],[9.54079242163154,46.776831352419556],[9.540883616738046,46.77707382120975],[9.540390090279306,46.77715097014131],[9.540411547951425,46.77732731014122],[9.541339592270578,46.77721342395731],[9.541398600868906,46.77744486982035],[9.540320352844919,46.77770203072362]]}'from customers where company_id=#{company_id} and name ='Gemeinde Churwalden'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Gobbi','Sonnweg','3','5746','Walterswil',id,TRUE,'2020-09-16 13:14','2020-09-16 13:14','Gobbi','Simon','{}'from customers where company_id=#{company_id} and name ='Gobbi'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Ambühl','Lindenweg','8','5746','Walterswil',id,TRUE,'2019-04-22 11:47','2020-09-16 13:15','Parkplatz Lindenweg','Daniela','{"type":"LineString","coordinates":[[7.963717169415343,47.32362348991514],[7.96342480863272,47.3236125809955],[7.963427490841735,47.323752578626596],[7.96354550803839,47.3236271262212],[7.9636554786080005,47.323674398177054],[7.963427490841735,47.32376348751733],[7.962609417092192,47.3237725782579],[7.9623814293259265,47.32361621730232],[7.9622580477112415,47.32330713033079]]}'from customers where company_id=#{company_id} and name ='Gobbi'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Gyger','Tödistrasse','12','8418','Schlatt',id,TRUE,'2020-05-21 16:50','2020-09-16 13:21','Tödistrasse','Aron','{"type":"LineString","coordinates":[[8.700753367364293,47.66209844660943],[8.700098908364659,47.66168656933146],[8.700281298577671,47.66144811258002],[8.700731909692173,47.66118797669987],[8.701418555199986,47.66096396976435],[8.7025558118223,47.66073273579052]]}'from customers where company_id=#{company_id} and name ='Gyger'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Hässig','Blauäcker','12','8887','Mels',id,TRUE,'2020-09-16 13:32','2020-09-16 13:32','Blauäcker','Gabriela','{"type":"LineString","coordinates":[[9.424942390994108,47.04401171445022],[9.430510656909025,47.04644622825779],[9.430789606646574,47.046841003811295],[9.429459230975187,47.04828596324234]]}'from customers where company_id=#{company_id} and name ='Hässig'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Gerold','Bahnhofstrasse','45','6390','Engelberg',id,TRUE,'2020-05-21 15:57','2020-09-16 13:38','Parkplatz Bahnhof','Heinz','{"type":"LineString","coordinates":[[8.39979137199624,46.819552044496746],[8.400461924249964,46.81941255155307],[8.40005959289773,46.81985672519423],[8.400644314462976,46.81985672519423],[8.40132023113473,46.819695207931076],[8.40206052082284,46.81971356218996]]}'from customers where company_id=#{company_id} and name ='Immobilien Engelberg'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Immobilien Engelberg','Haldenstrasse','3','6390','Engelberg',id,TRUE,'2020-09-16 13:42','2020-09-16 13:42','Immobilien Engelberg','z.H. Jordan Beatrice','{"type":"Point","coordinates":[8.400737017347426,46.82286728089036]}'from customers where company_id=#{company_id} and name ='Immobilien Engelberg'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Bernegger','Bankstrasse','5','4417','Ziefen',id,TRUE,'2020-05-21 16:42','2020-09-16 13:43','Bankstrasse','Leon','{"type":"LineString","coordinates":[[7.705546149410973,47.431481171812756],[7.7048702327392204,47.4318876042967],[7.703850993313561,47.43287464154726],[7.703260907330285,47.432954474633284],[7.702166566052209,47.43275852047863],[7.701007851757775,47.43210533469338]]}'from customers where company_id=#{company_id} and name ='Immobilien Engelberg'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Frei','Güterstrasse','','4417','Ziefen',id,TRUE,'2020-05-21 16:44','2020-09-16 13:44','Vorplatz Frei','Julian','{"type":"LineString","coordinates":[[7.7037835259611365,47.43284414034373],[7.7037446339304205,47.432787894200516],[7.703947140711045,47.432654536169096],[7.704011513727402,47.432689916904245]]}'from customers where company_id=#{company_id} and name ='Immobilien Engelberg'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Lustenberger','Industriestrasse','153','4222','Zwingen',id,TRUE,'2020-05-21 16:47','2020-09-16 13:52','Industriestrasse','Elena','{"type":"LineString","coordinates":[[7.531008596429345,47.43839443496512],[7.528326387414452,47.43771229157672],[7.5287984562010735,47.437131737046045],[7.52862679482412,47.43626089323956],[7.528970117578027,47.435738380037655],[7.52963530541372,47.435288433956096],[7.530515069970605,47.43505620221516]]}'from customers where company_id=#{company_id} and name ='Lustenberger'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Marti','Eigenstrasse','3','8887','Mels',id,TRUE,'2020-09-16 13:56','2020-09-16 13:56','Eigenstrasse','José','{"type":"LineString","coordinates":[[9.418750612172087,47.04448977737452],[9.417495338353117,47.04363438894755],[9.417355863484342,47.04377329911212]]}'from customers where company_id=#{company_id} and name ='Marti'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Marty','Herrengasse','3','1973','Nax',id,TRUE,'2020-05-21 16:31','2020-09-16 14:2','Marty','Daniela','{"type":"Point","coordinates":[7.428113436885746,46.22842300901357]}'from customers where company_id=#{company_id} and name ='Marty'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Moor','Dreispitz','3','7270','Davos',id,TRUE,'2020-05-21 16:19','2020-09-16 14:4','Geschäftsparkplatz','Martina','{"type":"Point","coordinates":[9.83257660814969,46.802561351991365]}'from customers where company_id=#{company_id} and name ='Moor'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Portier','Ringstrasse','1','8824','Schönenberg',id,TRUE,'2020-05-21 16:54','2020-09-16 14:11','Ringstrasse','Leo','{"type":"LineString","coordinates":[[8.6501225273481,47.197197717728706],[8.650111798512041,47.19753305664019],[8.64888871120125,47.19822559768423],[8.647343758808672,47.19729248763592],[8.646345977055132,47.19701546743141],[8.645766619907915,47.19706649757775],[8.6456378738752,47.19662180465297],[8.64614212917,47.19674573584265],[8.64666784213692,47.1964614226837],[8.647354487644732,47.19601672468802],[8.649619817733765,47.197287301646504],[8.649457339512407,47.197234167713056],[8.650090340839922,47.197190427728835]]}'from customers where company_id=#{company_id} and name ='Portier'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Schmid','Sternenplatz','6','6467','Schattdorf',id,TRUE,'2020-09-16 14:15','2020-09-16 14:15','Sternenplatz','Roger','{"type":"Point","coordinates":[8.641530853359084,46.85901281014221]}'from customers where company_id=#{company_id} and name ='Schmid'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Stettler','Pilatusweg','3','6467','Schattdorf',id,TRUE,'2020-09-16 14:19','2020-09-16 14:20','Pilatusweg','Rudolf','{"type":"LineString","coordinates":[[8.647909936486453,46.86145433773535],[8.647416410027713,46.86131495353893],[8.64623623806116,46.860566674298745],[8.645152625619144,46.86017785841934]]}'from customers where company_id=#{company_id} and name ='Stettler'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Suter','Brand','','1973','Nax',id,TRUE,'2020-05-21 16:34','2020-09-16 14:23','Besucherparkplatz Brand','Nadine','{"type":"LineString","coordinates":[[7.424810326930031,46.22645425877161],[7.424896157618508,46.22631137903153],[7.425786651011452,46.226151798622446]]}'from customers where company_id=#{company_id} and name ='Suter'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Vetsch','Arosastrasse','3','1680','Romont',id,TRUE,'2020-05-21 16:39','2020-09-16 14:26','Treppe','Tim','{"type":"Point","coordinates":[6.917811954292752,46.694755400251736]}'from customers where company_id=#{company_id} and name ='Waber'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Luchsinger','Aegertenweg','','9200','Gossau',id,TRUE,'2020-05-21 16:9','2020-09-16 14:31','MFH Aegertenweg','Cornelia','{"type":"LineString","coordinates":[[9.243489437396851,47.42027038039533],[9.24375765829834,47.42077852872281],[9.245715670879212,47.420553492211425],[9.24578004389557,47.42004534171193]]}'from customers where company_id=#{company_id} and name ='Zimmermann'LIMIT 1;
INSERT INTO public.sites ("name",street,nr,zip,city,customer_id,active,created_at,updated_at,display_name,first_name,area_json) SELECT'Stüssi','Bogenweg','7','9200','Gossau',id,TRUE,'2020-05-21 16:9','2020-09-16 14:33','Bogenweg','Franziska','{"type":"LineString","coordinates":[[9.244394754342542,47.417600511234674],[9.24670145409535,47.41844988518541],[9.24945876496266,47.4188999752291],[9.249630426339612,47.41842810653733],[9.24693748848866,47.41799253168376],[9.246615623406873,47.41838454921414]]}'from customers where company_id=#{company_id} and name ='Zimmermann'LIMIT 1;
SQL
  end
end
