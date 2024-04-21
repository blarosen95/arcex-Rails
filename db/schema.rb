# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 20_240_421_134_515) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'assets', force: :cascade do |t|
    t.string 'code'
    t.string 'name'
    t.boolean 'fiat'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'contents', force: :cascade do |t|
    t.bigint 'wallet_id', null: false
    t.string 'currency'
    t.decimal 'balance', precision: 10, scale: 2, default: '0.0'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['wallet_id'], name: 'index_contents_on_wallet_id'
  end

  create_table 'orders', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.string 'currency', null: false
    t.decimal 'amount', precision: 30, scale: 18, null: false
    t.integer 'order_type', null: false
    t.integer 'status', default: 0, null: false
    t.decimal 'price', precision: 30, scale: 18
    t.integer 'direction', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['user_id'], name: 'index_orders_on_user_id'
  end

  create_table 'trades', force: :cascade do |t|
    t.bigint 'order_id', null: false
    t.integer 'status', default: 0, null: false
    t.decimal 'executed_price', precision: 30, scale: 18
    t.decimal 'executed_amount', precision: 30, scale: 18
    t.decimal 'fee', precision: 30, scale: 18
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['order_id'], name: 'index_trades_on_order_id'
  end

  create_table 'transactions', force: :cascade do |t|
    t.bigint 'sender_id', null: false
    t.bigint 'recipient_id', null: false
    t.string 'currency'
    t.decimal 'amount', precision: 30, scale: 18
    t.integer 'status', default: 0, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['recipient_id'], name: 'index_transactions_on_recipient_id'
    t.index %w[sender_id recipient_id], name: 'index_transactions_on_sender_id_and_recipient_id'
    t.index ['sender_id'], name: 'index_transactions_on_sender_id'
    t.check_constraint 'sender_id <> recipient_id', name: 'sender_recipient_different'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'email', default: '', null: false
    t.string 'encrypted_password', default: '', null: false
    t.string 'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.integer 'sign_in_count', default: 0, null: false
    t.datetime 'current_sign_in_at'
    t.datetime 'last_sign_in_at'
    t.string 'current_sign_in_ip'
    t.string 'last_sign_in_ip'
    t.string 'confirmation_token'
    t.datetime 'confirmed_at'
    t.datetime 'confirmation_sent_at'
    t.string 'unconfirmed_email'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'username', null: false
    t.boolean 'is_admin', default: false
    t.index ['email'], name: 'index_users_on_email', unique: true
    t.index ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true
  end

  create_table 'wallets', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.string 'name'
    t.text 'currencies', default: [], array: true
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['user_id'], name: 'index_wallets_on_user_id'
  end

  add_foreign_key 'contents', 'wallets'
  add_foreign_key 'orders', 'users'
  add_foreign_key 'trades', 'orders'
  add_foreign_key 'transactions', 'wallets', column: 'recipient_id'
  add_foreign_key 'transactions', 'wallets', column: 'sender_id'
  add_foreign_key 'wallets', 'users'
end
