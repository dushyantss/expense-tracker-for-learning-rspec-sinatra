# frozen_string_literal: true

require 'sinatra/base'
require 'json'

module ExpenseTracker
  # The base API class for our project
  class API < Sinatra::Base
    post '/expenses' do
    end
  end
end
