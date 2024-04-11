# ? TODO: Replace with AWS Credentials Manager / similar after MVP:
require 'dotenv'
Dotenv.load('arcex.dev.env')

# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!
