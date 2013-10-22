require 'sinatra/base'
require 'digest/md5'
require './lib/idea_box'

module Sinatra
  module Auth
    module Helpers

      def authorized?
        session[:user]
      end

      def protected!
        halt 401, erb(:unauthorized) unless authorized?
      end
    end

    def self.registered(app)
      app.helpers Helpers
      app.enable :sessions
      app.get '/session/login' do
        erb :login
      end

      app.post '/session/login' do
        user = UserStore.find_by_username(params[:username].downcase)
        login_try = Digest::MD5.hexdigest(params[:password])
        if user && user.password == login_try
          session[:persona] = params[:username]
          user.load_databases
          redirect to "/"
        else


