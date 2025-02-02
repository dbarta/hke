# db/seeds.rb
require_relative "api_seeds_executor"

max_num_people = (ARGV.length > 0) ? ARGV[0].to_i : 1000
executor = ApiSeedsExecutor.new(max_num_people)

puts "@@@ Running hke/db/seeds.rb file. Setting locale to :he. Importing no more than #{max_num_people} deceased people."

executor.clear_database
executor.init_api_client
# executor.process_csv(Hke::Engine.root.join("db", "deceased_2022_02_28_no_blanks.csv"))
# executor.summarize
