require 'fileutils'
require 'rake'

namespace :setup do
  desc 'Create arcex.dev.env file if needed (and fill it with some default values)'
  task :env do
    env_path = Dir.pwd
    env_file = File.join(env_path, 'arcex.dev.env')

    # Check if the certificate files exist
    if File.exist?(env_file)
      puts 'SSL certificates already exist.'
    else
      puts 'Generating arcex.dev.env file...'
      system("touch #{env_file}")

      File.open(env_file, 'w') do |f|
        f.puts "HASH_ID_SALT_2=#{SecureRandom.hex(11)}"

        puts "arcex.dev.env file generated at #{env_path}"
      end
    end
  end
end

# Default task
task default: 'setup:env'
