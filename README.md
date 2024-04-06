# README

ARCEX Server is the backend for the ARCEX platform. This README documents the steps necessary to get it up and running.

* Assumptions
    - You have `homebrew` installed.
    - You have `rvm` installed.

* Ruby version
    - 3.1.4 (use `rvm install 3.1.4` to install ruby 3.1.4 inside of a Ruby version manager)

* System dependencies
    - `brew install postgresql` to install postgresql

* Configuration
    - `bundle install` to install all the gems
    - `rake setup:ssl` to create a self-signed SSL certificate and key for local development environments
    - `rake setup:env` to create the `arcex.dev.env` file for managing secrets/env-variables in local development environments

* Database creation
    - `rake db:create` to create the database

* Database initialization
    - `rake db:migrate` to run the migrations

* How to run the test suite
    - TBD (but likely via `rspec [foo]`)

* Services (job queues, cache servers, search engines, etc.)
    - TBD (will likely want Redis and/or RabbitMQ and/or SideKiq)

* Deployment instructions
    - TBD
