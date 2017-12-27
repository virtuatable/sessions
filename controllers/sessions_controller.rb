# frozen_string_literal: true

# Main controller of the application, creating and destroying sessions.
# @author Vincent Courtois <courtois.vincent@outlook.com>
class SessionsController < Arkaan::Utils::Controller

  post '/' do
    check_presence('username', 'password')

    account = Arkaan::Account.where(username: params['username']).first
    password = params['password']

    if account.nil?
      halt 404, {message: 'account_not_found'}.to_json
    elsif BCrypt::Password.new(account.password_digest) != password
      halt 403, {message: 'wrong_password'}.to_json
    else
      expiration = params['expiration'] || 3600
      session = account.sessions.create(token: SecureRandom.hex, expiration: expiration)
      halt 201, Decorators::Session.new(session).to_json
    end
  end

  get '/:id' do
    session = Arkaan::Authentication::Session.where(token: params['id']).first

    if session.nil?
      halt 404, {message: 'session_not_found'}.to_json
    else
      halt 200, Decorators::Session.new(session).to_json
    end
  end
end
