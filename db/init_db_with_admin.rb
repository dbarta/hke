# db/init_db_with_admin.rb
require_relative "api_seeds_executor"

max_num_people = (ARGV.length > 0) ? ARGV[0].to_i : 1000
executor = ApiSeedsExecutor.new(max_num_people)

puts "@@@ Running hke/db/init_db_with_admin.rb file. "

executor.clear_database
executor.init_api_client
