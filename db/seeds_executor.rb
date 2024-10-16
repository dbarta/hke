# seeds_executor.rb
require_relative "seeds_helper"

class SeedsExecutor
  include SeedsHelper

  def initialize(max_num_people)
    @max_num_people = max_num_people
    @logger = log("import_csv.log")
    @error = log("import_csv_errors.log")
    @num_errors = 0
    I18n.locale = :he
  end

  def clear_database
    Hke::FutureMessage.delete_all
    Hke::Relation.delete_all
    Hke::DeceasedPerson.delete_all
    Hke::ContactPerson.delete_all
    Hke::Cemetery.delete_all

    AccountUser.delete_all
    Hke::System.delete_all
    Hke::Community.delete_all

    ApiToken.delete_all

    Account.delete_all
    User.delete_all
  end

  def create_users_and_accounts
    Hke::System.create!(product_name: "Hakhel", version: "0.1")
    admin_user = User.create!(name: "admin", email: "david@odeca.net", password: "password", terms_of_service: true, admin: true)
    account = Account.create!(name: "Kfar Vradim", owner: admin_user, personal: false, billing_email: "david@odeca.net")
    community = Hke::Community.create!(name: "Kfar Vradim Synagogue", community_type: "synagogue", account: account)

    # Set the current tenant for multi-tenancy
    ActsAsTenant.current_tenant = community
  end

  def process_csv(file_path)
    @logger.info "Start processing #{file_path}"
    he_to_en_relations = []
    he_to_en_relations = relations_select

    csv_text = File.read(file_path)
    csv = CSV.parse(csv_text, headers: true, encoding: "UTF-8")
    csv.each_with_index do |row, index|
      @line_no = index + 2
      break if @line_no > @max_num_people
      dp = Hke::DeceasedPerson.new
      dp.first_name = row["שם פרטי של נפטר"]
      dp.last_name = row["שם משפחה של נפטר"]
      dp.hebrew_year_of_death = row["שנת פטירה"]
      dp.hebrew_month_of_death = row["חודש פטירה"]
      dp.hebrew_day_of_death = row["יום פטירה"]
      dp.gender = ((row["מין של נפטר"] == "זכר") ? "male" : "female")
      dp.father_first_name = row["אבא של נפטר"]
      dp.mother_first_name = row["אמא של נפטר"]
      dp.cemetery = create_or_find_cemetery(row["מיקום בית קברות"])
      dp = create_or_find_deceased_person(dp)

      if dp.errors.any?
        puts "Errors in row #{@line_no}: #{dp.name}"
        dp.errors.full_messages.each { |message| puts message }
        next
      end
      sleep(0.1) # Avoid API rate limit

      next unless row["שם פרטי איש קשר"] || row["שם משפחה איש קשר"]

      cp = Hke::ContactPerson.new
      cp.first_name = row["שם פרטי איש קשר"]
      cp.last_name = row["שם משפחה איש קשר"]
      cp.email = row["אימייל איש קשר"]
      cp.phone = row["טלפון איש קשר"]
      cp.gender = ((row["מין של איש קשר"] == "זכר") ? "male" : "female")
      cp = create_or_find_contact_person(cp, dp)

      heb_rel = row[0]
      next unless heb_rel

      pair = he_to_en_relations.find { |a| a[0] == heb_rel }
      next unless pair

      eng_rel = pair[1]
      r = Hke::Relation.new
      r.deceased_person = dp
      r.contact_person = cp
      r.relation_of_deceased_to_contact = eng_rel
      create_or_find_relation(r)
    end
  end

  def summarize
    @logger.info "There are #{Hke::DeceasedPerson.count} deceased people, and #{Hke::ContactPerson.count} contacts"
    @error.info "There were #{@num_errors} errors in input csv file."
  end
end
