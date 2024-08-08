# README
**This project is now open-source.**

ARCEX Server is the backend for the ARCEX platform. This README documents the steps necessary to get it up and running.

- Assumptions

  - You have `homebrew` installed (https://docs.brew.sh/Installation).
  - You have `rvm` installed (https://rvm.io/rvm/install).
    - Follow the guide's `Install GPG Keys` and `Install RVM (development version)` sections (should be just two commands)

- Ruby version

  - 3.1.4 (use `rvm install 3.1.4` to install ruby 3.1.4 inside of a Ruby version manager)

- System dependencies

  - `brew install postgresql` to install postgresql

- Configuration

  - `bundle install` to install all the gems
  - `rake setup:ssl` to create a self-signed SSL certificate and key for local development environments
  - `rake setup:env` to create the `arcex.dev.env` file for managing secrets/env-variables in local development environments

- Database creation

  - `rake db:create` to create the database

- Database initialization

  - `rake db:migrate` to run the migrations
  - `rake db:seed` will add two fake users to the DB (can be helpful for stuff like transferring between wallets currently)

- How to run the test suite

  - TBD (but likely via `rspec [foo]`)

- Services (job queues, cache servers, search engines, etc.)

  - TBD (will likely want Redis and/or RabbitMQ and/or SideKiq)

- Deployment instructions
  - TBD

## Windows Dev Environment Setup
- Download and install Ruby 3.1.4 from https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.1.4-1/rubyinstaller-devkit-3.1.4-1-x64.exe
  - Install for all users
- Instead of running the `rake setup:ssl` task, you can copy and paste both `cert.pem` and `key.pem` (from the frontend project) into this project's `.cert/` folder.
- Download and install PostgreSQL 14 from https://sbp.enterprisedb.com/getfile.jsp?fileid=1258897
  - Remember the super admin password you choose during the installation process.
  - You should NOT need to proceed with the Stack Builder installer
  - Open `C:\Program Files\PostgreSQL\14\data\pg_hba.conf` in notepad (or really any editor you'd like) and make these changes:
    - Find `METHOD` in the file's contents towards the very end.
    - Below that heading section that ends in "METHOD", you will see the phrase `scram-sha-256` maybe 6 times.
    - Replace the first three occurrences of `scram-sha-256` with `trust`
    - Save the file, you may also exit the editor if desired as no further changes to the file are needed.
- Open a command prompt **AS ADMIN** and run:
  - `cd C:\Program Files\PostgreSQL\14\bin`
  - `psql -U postgres`
  - Enter the password supplied during PostgreSQL installation
  - Run `CREATE ROLE root WITH LOGIN SUPERUSER CREATEDB CREATEROLE;`
  - Run `\q` to exit out of the CLI for psql
  - Change directory in CMD to this backend app repo's folder using `cd` command and a full path to the root of this project on your local system.
  - Run `bundle install`
  - run `rake setup:env`
  - run `rake db:create db:migrate db:seed`
  - You should (assuming you've already copied over the cert files from the frontend project) now be able to run `rails s` to start the server.
