namespace :Hke do
    desc 'Load the seed data for EngineName'
    task :seed do
      seed_file = Hke::Engine.root.join('db', 'seeds.rb')
      if File.exist?(seed_file)
        puts "Loading seed data for hke..."
        require seed_file
      else
        puts "No seeds to load for hke"
      end
    end
  end
  