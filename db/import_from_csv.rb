# db/import_from_csv.rb
require_relative "api_seeds_executor"
require_relative "../lib/hke/loggable"
include Hke::Loggable
puts "@@@@ 1"
max_num_people = (ARGV.length > 0) ? ARGV[0].to_i : 1000
puts "@@@@ 2"
init_logging "api_import_csv"
puts "@@@@ 3"
log_info "@@@ Running hke/db/import_from_csv.rb file. Setting locale to :he. Importing no more than #{max_num_people} deceased people."
executor = ApiSeedsExecutor.new(max_num_people)
executor.process_csv(Hke::Engine.root.join("db", "deceased_2022_02_28_no_blanks.csv"))
#executor.process_csv(Hke::Engine.root.join("db", "test_deceased_1_deceased.csv"))
#executor.process_csv(Hke::Engine.root.join("db", "deceased_2022_02_28_no_blanks_wrong_gender.csv"))
executor.summarize
