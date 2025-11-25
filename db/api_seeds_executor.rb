# require 'httparty'
require 'csv'
require 'set'
require 'digest/md5'
require 'base64'
require 'net/http'
require 'uri'
require 'marcel'
require 'pathname'

require_relative '../lib/hke/api_helper.rb'
require_relative '../lib/hke/log_helper.rb'
require_relative '../lib/hke/loggable.rb'

class ApiSeedsExecutor
  include Hke::ApiHelper
  include Hke::Loggable
  include Hke::ApplicationHelper

  def initialize(max_num_people)
    @max_num_people = max_num_people
    I18n.locale = :he
    @num_errors = 0
    @new_deceased = 0
    @existing_deceased = 0
    @new_contacts = 0
    @existing_contacts = 0
    @total_rows = 0
    @processed_rows = 0
    @counted_deceased_ids = Set.new
    @counted_contact_ids = Set.new
    @counted_new_deceased_ids = Set.new
    @counted_new_contact_ids = Set.new
    @csv_import_id = nil
  end

  def process_row(row)
    log_info "@@@ Processing row #{@line_no}: deceased #{row['שם פרטי של נפטר']} #{row['שם משפחה של נפטר']}"

    @cemetery_id = create_or_find_cemetery(row["מיקום בית קברות"])

    # Process deceased person
    dp_data = {
      first_name: row["שם פרטי של נפטר"],
      last_name: row["שם משפחה של נפטר"],
      hebrew_year_of_death: row["שנת פטירה"],
      hebrew_month_of_death: row["חודש פטירה"],
      hebrew_day_of_death: row["יום פטירה"],
      gender: ((row["מין של נפטר"] == "זכר") ? "male" : "female"),
      father_first_name: row["אבא של נפטר"],
      mother_first_name: row["אמא של נפטר"],
      cemetery_id: @cemetery_id
    }

    dp_response = post("#{@hke_url}/deceased_people", dp_data, raise: false)
    unless dp_response.success?
      cp_full = "#{row['שם פרטי איש קשר']} #{row['שם משפחה איש קשר']}".strip
      log_error "Row #{@line_no}: failed to create deceased '#{dp_data[:first_name]} #{dp_data[:last_name]}' (contact: '#{cp_full}'). Response: #{dp_response.body}"
      @num_errors += 1
      create_csv_log(:error, "Failed to create deceased #{dp_data[:first_name]} #{dp_data[:last_name]}: #{dp_response.body}")
      return
    end
    dp_id = dp_response["id"]
    dp_status = dp_response["dedup_status"]
    already_new = dp_id && @counted_new_deceased_ids.include?(dp_id)
    already_seen = dp_id && @counted_deceased_ids.include?(dp_id)

    if dp_status == "created"
      unless already_new
        @new_deceased += 1
        @counted_new_deceased_ids << dp_id if dp_id
      end
    else
      unless already_new || already_seen
        @existing_deceased += 1
      end
    end

    @counted_deceased_ids << dp_id if dp_id
    log_info "@@@ Deceased '#{dp_data[:first_name]}' id: #{dp_id} (#{dp_status}) processed."
    create_csv_log(:info, "Processed deceased #{dp_data[:first_name]} #{dp_data[:last_name]} (#{dp_status})", row_number: @line_no)

    # Contact + relation must both be valid to proceed
    contact_data_exists = false
    relation_pair = nil
    if row["שם פרטי איש קשר"] || row["שם משפחה איש קשר"]
      if row[0]
        relation_pair = @he_to_en_relations.find { |a| a[0] == row[0] }
        contact_data_exists = true if relation_pair
      end
    end

    unless contact_data_exists
      cp_full = "#{row['שם פרטי איש קשר']} #{row['שם משפחה איש קשר']}".strip
      log_error "Row #{@line_no}: missing or invalid contact/relationship for deceased '#{dp_data[:first_name]} #{dp_data[:last_name]}'. Contact: '#{cp_full}'."
      @num_errors += 1
      create_csv_log(:error, "Missing or invalid contact for #{dp_data[:first_name]} #{dp_data[:last_name]}")
      return
    end

    cp_data = {
      first_name: row["שם פרטי איש קשר"],
      last_name: row["שם משפחה איש קשר"],
      email: row["אימייל איש קשר"],
      phone: row["טלפון איש קשר"],
      gender: ((row["מין של איש קשר"] == "זכר") ? "male" : "female")
    }

    cp_response = post("#{@hke_url}/contact_people", cp_data, raise: false)
    unless cp_response.success?
      log_error "Row #{@line_no}: failed to create contact '#{cp_data[:first_name]} #{cp_data[:last_name]}' for deceased '#{dp_data[:first_name]} #{dp_data[:last_name]}'. Response: #{cp_response.body}"
      @num_errors += 1
      create_csv_log(:error, "Failed to create contact #{cp_data[:first_name]} #{cp_data[:last_name]}: #{cp_response.body}")
      return
    end
    cp_id = cp_response["id"]
    cp_status = cp_response["dedup_status"]
    contact_already_new = cp_id && @counted_new_contact_ids.include?(cp_id)
    contact_already_seen = cp_id && @counted_contact_ids.include?(cp_id)

    if cp_status == "created"
      unless contact_already_new
        @new_contacts += 1
        @counted_new_contact_ids << cp_id if cp_id
      end
    else
      unless contact_already_new || contact_already_seen
        @existing_contacts += 1
      end
    end

    @counted_contact_ids << cp_id if cp_id
    log_info "@@@ Contact '#{cp_data[:first_name]}' id: #{cp_id} (#{cp_status}) for deceased '#{dp_data[:first_name]}' processed."
    create_csv_log(:info, "Processed contact #{cp_data[:first_name]} #{cp_data[:last_name]} (#{cp_status})", row_number: @line_no)

    relation_data = {
      deceased_person_id: dp_id,
      contact_person_id: cp_id,
      relation_of_deceased_to_contact: relation_pair[1]
    }

    relation_response = post("#{@hke_url}/relations", relation_data, raise: false)
    unless relation_response.success?
      log_error "Row #{@line_no}: failed to create relation '#{relation_pair[1]}' between contact '#{cp_data[:first_name]} #{cp_data[:last_name]}' and deceased '#{dp_data[:first_name]} #{dp_data[:last_name]}'. Response: #{relation_response.body}"
      @num_errors += 1
      create_csv_log(:error, "Failed to create relation #{relation_pair[1]} between #{cp_data[:first_name]} and #{dp_data[:first_name]}: #{relation_response.body}")
      return
    end
    rel_status = relation_response["dedup_status"]
    log_info "@@@ Relation (#{relation_data[:relation_of_deceased_to_contact]}) created/used (#{rel_status}) for deceased '#{dp_data[:first_name]}' and contact '#{cp_data[:first_name]}'."
    create_csv_log(:info, "Relation #{relation_data[:relation_of_deceased_to_contact]} created/used (#{rel_status})", row_number: @line_no)

    sleep(0.1) # Maintain rate limiting
  ensure
    @processed_rows += 1
    update_csv_import!
  end

  def process_row_as_one(row)
    log_info "@@@ Processing deceased: #{row['שם פרטי של נפטר']}"

    @cemetery_id = create_or_find_cemetery(row["מיקום בית קברות"])

    # Process deceased person
    dp_data = {
      deceased_person: {
        first_name: row["שם פרטי של נפטר"],
        last_name: row["שם משפחה של נפטר"],
        hebrew_year_of_death: row["שנת פטירה"],
        hebrew_month_of_death: row["חודש פטירה"],
        hebrew_day_of_death: row["יום פטירה"],
        gender: ((row["מין של נפטר"] == "זכר") ? "male" : "female"),
        father_first_name: row["אבא של נפטר"],
        mother_first_name: row["אמא של נפטר"],
        cemetery_id: @cemetery_id
      }
    }

    contact_data_exists = false
    if row["שם פרטי איש קשר"] || row["שם משפחה איש קשר"]
      if row[0] # The relationship must exist
        pair = @he_to_en_relations.find { |a| a[0] == row[0] }
        if pair
          log_info "CSV file contains valid contact info for #{row['שם פרטי של נפטר']} with relationship #{pair[1]}."
          contact_data_exists = true
          dp_data[:deceased_person][:relations_attributes] = [
            {
              relation_of_deceased_to_contact: pair[1],
              contact_person_attributes: {
                first_name: row["שם פרטי איש קשר"],
                last_name: row["שם משפחה איש קשר"],
                email: row["אימייל איש קשר"],
                phone: row["טלפון איש קשר"],
                gender: ((row["מין של איש קשר"] == "זכר") ? "male" : "female")
              }
            }
          ]
        end
      end
    end
    log_error "Missing or invalid contact info for: #{row['שם פרטי של נפטר']}." unless contact_data_exists

    dp_response = post("#{@hke_url}/deceased_people", dp_data, raise: false)
    log_info "@@@ Deceased: #{row['שם פרטי של נפטר']} id: #{dp_response[:id]} processed."

    sleep(0.1) # Maintain rate limiting
  end

  def process_csv(file_path)
    log_info "@@@ Start processing #{file_path}"
    init_api
    @he_to_en_relations = relations_select
    create_csv_import_record(file_path)

    csv_text = File.read(file_path)
    csv = CSV.parse(csv_text, headers: true, encoding: "UTF-8")
    csv.each_with_index do |row, index|
      @line_no = index + 1
      break if @line_no > @max_num_people
      @total_rows += 1
      process_row row
    end

    finalize_csv_import
  end

  def summarize
    ok_rows = @total_rows - @num_errors
    total_unique_deceased = @counted_deceased_ids.size
    total_unique_contacts = @counted_contact_ids.size

    log_info "Rows: total #{@total_rows}, ok #{ok_rows}, errors #{@num_errors}"
    log_info "Deceased: total #{total_unique_deceased}, new #{@new_deceased}, existing #{@existing_deceased}"
    log_info "Contacts: total #{total_unique_contacts}, new #{@new_contacts}, existing #{@existing_contacts}"

    create_csv_log(:info, "Summary: rows=#{@total_rows}, errors=#{@num_errors}")
    create_csv_log(:info, "Deceased totals: total=#{total_unique_deceased}, new=#{@new_deceased}, existing=#{@existing_deceased}")
    create_csv_log(:info, "Contact totals: total=#{total_unique_contacts}, new=#{@new_contacts}, existing=#{@existing_contacts}")
  end

  private

  def deceased_key_from_row(row)
    [
      row["שם פרטי של נפטר"],
      row["שם משפחה של נפטר"],
      row["שנת פטירה"],
      row["חודש פטירה"],
      row["יום פטירה"]
    ].map { |value| value.to_s.strip.downcase }.join("|")
  end

  def get_count(resource)
    response = HTTParty.get("#{@hke_url}/#{resource}/count", headers: @headers)
    response.success? ? response.parsed_response["count"] : 0
  end

  def log_errors(response, resource)
    @error.error "Errors in row #{@line_no} for #{resource}: #{response.body}"
    @num_errors += 1
  end

  def upload_file_to_active_storage(file_path)
    metadata = request_direct_upload_metadata(file_path)
    upload_direct_file(file_path, metadata["direct_upload"])
    metadata["signed_id"]
  end

  def request_direct_upload_metadata(file_path)
    checksum = Base64.strict_encode64(Digest::MD5.file(file_path).digest)
    content_type = Marcel::MimeType.for(Pathname.new(file_path), name: File.basename(file_path)) || 'text/csv'
    payload = {
      blob: {
        filename: File.basename(file_path),
        content_type: content_type,
        byte_size: File.size(file_path),
        checksum: checksum
      }
    }
    post("#{@API_URL}/rails/active_storage/direct_uploads", payload, headers: csrf_headers, raise: true)
  end

  def upload_direct_file(file_path, direct_upload)
    uri = URI.parse(direct_upload["url"])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    request = Net::HTTP::Put.new(uri)
    (direct_upload["headers"] || {}).each do |key, value|
      request[key] = value
    end
    request.body = File.binread(file_path)
    response = http.request(request)
    unless response.code.to_i.between?(200, 299)
      raise "Direct upload failed: #{response.code} #{response.body}"
    end
  end

  def create_csv_log(level, message, row_number: nil, details: nil)
    return unless @csv_import_id

    payload = {
      csv_import_log: {
        csv_import_id: @csv_import_id,
        level: level,
        row_number: row_number,
        message: message,
        details: details
      }
    }

    post("#{@hke_url}/csv_import_logs", payload, raise: false)
  end

  def create_csv_import_record(file_path)
    file_signed_id = upload_file_to_active_storage(file_path)

    payload = {
      csv_import: {
        name: File.basename(file_path),
        status: :processing,
        import_type: :combined,
        total_rows: 0,
        processed_rows: 0,
        successful_rows: 0,
        failed_rows: 0,
        total_deceased_in_input: 0,
        total_contacts_in_input: 0,
        new_deceased: 0,
        existing_deceased: 0,
        file: file_signed_id,
        user_id: system_user_id,
        community_id: current_community_id
      }
    }

    response = post("#{@hke_url}/csv_imports", payload, raise: true)
    @csv_import_id = response["id"]
    create_csv_log(:info, "CSV import started for #{payload[:csv_import][:name]}") if @csv_import_id
  end

  def update_csv_import!(status: nil)
    return unless @csv_import_id

    payload = {
      csv_import: {
        status: status || :processing,
        total_rows: @total_rows,
        processed_rows: @processed_rows,
        successful_rows: [@processed_rows - @num_errors, 0].max,
        failed_rows: @num_errors,
        total_deceased_in_input: @counted_deceased_ids.size,
        total_contacts_in_input: @counted_contact_ids.size,
        new_deceased: @new_deceased,
        existing_deceased: @existing_deceased
      }
    }

    patch("#{@hke_url}/csv_imports/#{@csv_import_id}", payload, raise: true)
  end

  def finalize_csv_import
    status = @num_errors.zero? ? :completed : :failed
    update_csv_import!(status: status)
    create_csv_log(:info, "CSV import finished with status #{status}")
  end

  def system_user_id
    @system_user_id ||= begin
      response = HTTParty.get("#{@API_URL}/users/current", headers: @headers)
      response.success? ? response.parsed_response["id"] : User.first&.id
    end
  end

  def current_community_id
    @current_community_id ||= Hke::Community.first&.id
  end
end
