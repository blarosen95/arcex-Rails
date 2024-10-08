require 'fileutils'
require 'rake'

namespace :setup do
  desc 'Create .cert folder and generate SSL certificates if needed'
  task :ssl do
    cert_path = File.join(Dir.pwd, '.cert')
    key_file = File.join(cert_path, 'key.pem')
    cert_file = File.join(cert_path, 'cert.pem')

    # Create the .cert directory if it doesn't exist
    FileUtils.mkdir_p(cert_path) unless Dir.exist?(cert_path)

    # Check if the certificate files exist
    if File.exist?(key_file) && File.exist?(cert_file)
      puts 'SSL certificates already exist.'
    else
      puts 'Generating SSL certificates...'

      # Generate certificates using mkcert
      # This command generates both key.pem and cert.pem
      system("mkcert -key-file #{key_file} -cert-file #{cert_file} localhost")

      puts "Certificates generated at #{cert_path}"
    end
  end
end

# Default task
task default: 'setup:ssl'
