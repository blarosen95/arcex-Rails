require 'fileutils'
require 'rake'

namespace :ssl do
  desc "Create .cert folder and generate SSL certificates if needed"
  task :setup do
    cert_path = File.join(Dir.pwd, '.cert')
    key_file = File.join(cert_path, 'key.pem')
    cert_file = File.join(cert_path, 'cert.pem')

    # Create the .cert directory if it doesn't exist
    FileUtils.mkdir_p(cert_path) unless Dir.exist?(cert_path)

    # Check if the certificate files exist
    unless File.exist?(key_file) && File.exist?(cert_file)
      puts "Generating SSL certificates..."

      # Generate certificates using mkcert
      # This command generates both key.pem and cert.pem
      system("mkcert -key-file #{key_file} -cert-file #{cert_file} localhost")

      puts "Certificates generated at #{cert_path}"
    else
      puts "SSL certificates already exist."
    end
  end
end

# Default task
task default: 'ssl:setup'
