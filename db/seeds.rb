require 'csv'
require_relative '../lib/hke/heb'
require 'logger'

include Hke::DeceasedPeopleHelper

def log filename
  log_path=Rails.root.join('db',filename)
  File.delete(log_path) if File.exist?(log_path)
  logger = Logger.new(log_path)
  logger.datetime_format = "%Y-%m-%d %H:%M"
  return logger
end

@logger = log "import_csv.log"
@error = log "import_csv_errors.log"
@num_errors = 0

def log_error msg
  @error.error msg
  @num_errors += 1
end

def create_or_find_cemetery cemetery_name
  return nil if cemetery_name == nil
  cemetery = Hke::Cemetery.find_by_name(cemetery_name)
  unless cemetery
    cemetery = Hke::Cemetery.create!(name: cemetery_name)
    @logger.info "Created cemetery: #{cemetery.name}"
  end
  return cemetery
end

def create_or_find_deceased_person dp
  existing_dp = Hke::DeceasedPerson.find_by(first_name: dp.first_name, last_name: dp.last_name,
            father_first_name: dp.father_first_name, mother_first_name: dp.mother_first_name)
  if existing_dp
    @logger.info "Deceased #{dp.name} already exists, using it for another contact."
    return existing_dp
  else
    if dp.save
      @logger.info "Deceased #{dp.name} saved."
    else
      @logger.error "There where #{dp.errors.count} errors:"
      dp.errors.full_messages.each do |message|
        @logger.info message
      end
    end
    return dp
  end
end

def create_or_find_contact_person cp, dp
  existing_cp = Hke::ContactPerson.find_by(first_name: cp.first_name, last_name: cp.last_name, phone: cp.phone, email: cp.email )
  if existing_cp
    @logger.info "Contact #{cp.name} already exists, connecting it to #{dp.name}"
    return existing_cp
  else
    cp.save
    @logger.info "Contact #{cp.name} saved, connecting it to #{dp.name}"
    return cp
  end
end

def create_or_find_relation r
  existing_r = Hke::Relation.find_by(deceased_person_id: r.deceased_person_id, contact_person_id: r.contact_person_id )
  if existing_r
    log_error "Line: #{@line_no} -- relation '#{r.relation_of_deceased_to_contact}' between: #{r.deceased_person.name} and #{r.contact_person.name} already exists, skipping."
  else
    r.save
    @logger.info "relation '#{r.relation_of_deceased_to_contact}' between: #{r.deceased_person.name} and #{r.contact_person.name} saved."
  end
end

def english_gender hebrew_gender
  he_en_pair = gender_select.find{|pair| pair[0]==hebrew_gender}
  he_en_pair ? he_en_pair[1] : nil
end

Hke::Relation.delete_all
Hke::DeceasedPerson.delete_all
Hke::ContactPerson.delete_all
Hke::Cemetery.delete_all
AccountUser.delete_all
Account.delete_all
User.delete_all
u=User.create(name: 'David', email: 'david@odeca.net', password: 'odeca111', terms_of_service: true, admin: true)
u=User.create(name: 'Admin', email: 'admin@hakhel.com', password: 'password', terms_of_service: true, admin: true)




he_to_en_relations = []
I18n.with_locale(:he) do
  he_to_en_relations = relations_select
end

def validate_hebrew_month m
  if m == nil
    "month is missing"
  end
end

def validate_names_and_gender row
  is_valid = true

  if row['שם פרטי של נפטר'] == nil || row['שם משפחה של נפטר'] == nil
    log_error "Line: #{@line_no} -- deceased first or last name is missing, skipping to next person"
    is_valid = false
  end

  if english_gender(row['מין של נפטר']) == nil
    log_error "Line: #{@line_no} -- deceased gender is missing or invalid, skipping to next person"
    is_valid = false
  end

  if english_gender(row['מין של איש קשר']) == nil
    log_error "Line: #{@line_no} -- contact person gender is missing or invalid, skipping to next person"
    is_valid = false
  end

  if row['שם פרטי איש קשר'] == nil || row['שם משפחה איש קשר'] == nil || row['טלפון איש קשר'] == nil
    log_error "Line: #{@line_no} -- one of contact person's first name, last name, phone number or gender is missing, skipping to next person."
    is_valid = false
  end

  return is_valid
end

def validate_and_normalize_hebrew_dates! row
  is_valid = true
  day = row['יום פטירה']
  month = row['חודש פטירה']
  year = row['שנת פטירה']

  dates_error = ""
  comma = ""
  if year == nil
    dates_error = "year is missing"
    comma = ", "
  end

  if month == nil
    dates_error += comma + "month is missing"
    comma = ", "
  elsif
    # We have a month, check if legal
    english_month = hebrew_month_to_english(month)
    if english_month == nil
      dates_error += comma + "unknown month: #{month} provided"
      comma = ", "
    else
      # normalize it so display will work properly
      month = english_month_to_hebrew(english_month)
    end
  end

  if day == nil
    dates_error += comma + "day is missing"
  elsif
    # We have a day, check if legal
    num = hebrew_date_numeric_value(day)
    if (1..31).include? num
      day = hebrew_day_select[num-1] # Array begins with 0
    else
      dates_error += comma + "illegal hebrew date #{day}"
    end
  end

  if dates_error != ""
    log_error "Line: #{@line_no} -- #{dates_error}, skipping to next person."
    is_valid = false
  end

  if is_valid
    # Normalized values for saving in database
    row['יום פטירה'] = day
    row['חודש פטירה'] = month
    row['שנת פטירה'] = year
  end

  return is_valid
end

csv_text = File.read(Hke::Engine.root.join('db', 'deceased_2022_02_28.csv')) #'d1.csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'UTF-8')

csv.each_with_index do |row, index|
  # puts "xxx", row, index
  # break if index > 2
  @line_no = index + 2 # For the logs

  break if @line_no > 20

  #next if !validate_names_and_gender(row)
  #next if !validate_and_normalize_hebrew_dates!(row)

  dp = Hke::DeceasedPerson.new
  #puts @line_no, row
  dp.first_name = row['שם פרטי של נפטר']
  dp.last_name = row['שם משפחה של נפטר']

  rlo = "\u202E"
  pdf = "\u202C"
  puts "Processing row #{@line_no}: #{dp.name}"


  dp.hebrew_year_of_death = row['שנת פטירה']
  dp.hebrew_month_of_death = row['חודש פטירה']
  dp.hebrew_day_of_death = row['יום פטירה']

  dp.gender = english_gender row['מין של נפטר']
  dp.occupation = row['']
  dp.organization = row['']
  dp.religion = 'יהודי'
  dp.father_first_name = row['אבא של נפטר']
  dp.mother_first_name = row['אמא של נפטר']

  dp.time_of_death = row['שעת פטירה']
  dp.location_of_death = 'ישראל'
  dp.cemetery_region = row['גוש']
  dp.cemetery_parcel = row['חלקה']
  dp.cemetery = create_or_find_cemetery row['מיקום בית קברות']

  dp = create_or_find_deceased_person(dp)
  sleep(0.1) # The hebcal date API limit 90 calls for every 10 seconds

  if row['שם פרטי איש קשר'] || row['שם משפחה איש קשר']

    cp = Hke::ContactPerson.new
    cp.first_name = row['שם פרטי איש קשר']
    cp.last_name = row['שם משפחה איש קשר']
    cp.email = row['אימייל איש קשר']
    cp.phone = row['טלפון איש קשר']
    cp.gender = english_gender row['מין של איש קשר']
    cp = create_or_find_contact_person(cp, dp)

    heb_rel = row[0] #row['יחס קירבה'] for some reason can't access the key of the first element
    unless heb_rel
      log_error "Line: #{@line_no} -- relation is missing between #{dp.name} and #{cp.name} - relation not created in database."
      next
    end

    pair = nil
    pair = he_to_en_relations.find{|a| a[0]==heb_rel}
    unless pair
      log_error "Line: #{@line_no} -- relation '#{heb_rel}' is invalid between #{dp.name} and #{cp.name} - relation not created in database."
      next
    end

    eng_rel = pair[1]

    r = Hke::Relation.new
    r.deceased_person = dp
    r.contact_person = cp
    r.relation_of_deceased_to_contact = eng_rel
    create_or_find_relation r
  end
end

@logger.info "There are #{Hke::DeceasedPerson.count} deceased people, and #{Hke::ContactPerson.count} contacts"
@error.info "There were #{@num_errors} errors in input csv file."