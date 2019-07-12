# frozen_string_literal: true

require 'sinatra/base'
require 'json'

module ExpenseTracker
  # The base API class for our project
  class API < Sinatra::Base
    post '/expenses' do
      JSON.generate('customer_id' => 42)
    end

    get '/expenses/:date' do
      JSON.generate([])
    end
  end
end
