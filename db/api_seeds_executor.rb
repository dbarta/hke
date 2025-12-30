require_relative '../lib/hke/api_helper'
require_relative '../lib/hke/log_helper'
require_relative '../lib/hke/loggable'
require_relative '../app/services/hke/import/csv_import_api_client'

class ApiSeedsExecutor
  include Hke::ApiHelper
  include Hke::Loggable
  include Hke::ApplicationHelper

  def initialize(max_num_people)
    @max_num_people = max_num_people
  end

  def process_csv(file_path)
    csv_client = Hke::Import::CsvImportApiClient.new(file_path: file_path, max_rows: @max_num_people)
    csv_client.run!
    @last_client = csv_client
  end

  def summarize
    @last_client&.summarize
  end
end
