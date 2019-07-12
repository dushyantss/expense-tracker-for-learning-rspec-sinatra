# frozen_string_literal: true

require_relative '../../../app/api'
require 'rack/test'

# The unit tests for the API
module ExpenseTracker
  RSpec.describe API do
    include Rack::Test::Methods

    let(:ledger) { instance_double('ExpenseTracker::Ledger') }
    let(:response) { JSON.parse(last_response.body) }

    def app
      API.new(ledger: ledger)
    end

    describe 'POST /expenses' do
      context 'when the expense is successfully recorded' do
        let(:expense) { { 'some' => 'data' } }

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(true, 417, nil))
        end

        it 'returns the expense id' do
          post '/expenses', JSON.generate(expense)

          expect(response).to include('expense_id' => 417)
        end

        it 'response with a 200 (OK)' do
          post '/expenses', JSON.generate(expense)

          expect(last_response.status).to eq(200)
        end
      end

      context 'when the expense fails validation' do
        let(:expense) { { 'some' => 'data' } }

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(false, 417, 'Expense incomplete'))
        end

        it 'returns an error message' do
          post '/expenses', JSON.generate(expense)

          expect(response).to include('error_message' => 'Expense incomplete')
        end

        it 'responds with a 422 (Unprocessable Entity)' do
          post '/expenses', JSON.generate(expense)

          expect(last_response.status).to eq(422)
        end
      end
    end

    describe 'GET /expenses/:date' do
      context 'when expenses exist on the given date' do
        let(:date) { '2017-06-10' }
        let(:expenses) do
          [{ 'payee' => 'Starbucks',
             'amount' => 5.75,
             'date' => '2017-06-10' },
           { 'payee' => 'Zoo',
             'amount' => 15.25,
             'date' => '2017-06-10' }]
        end

        before do
          allow(ledger).to receive(:expenses_on)
            .with(date)
            .and_return(expenses)
        end

        it 'returns the expense records as JSON' do
          get "/expenses/#{date}"

          expect(response).to eq(expenses)
        end

        it 'responds with a 200 (OK)' do
          get "/expenses/#{date}"

          expect(last_response.status).to eq(200)
        end
      end

      context 'when there are no expenses on the given date' do
        let(:date) { '2017-06-10' }
        let(:expenses) { [] }

        before do
          allow(ledger).to receive(:expenses_on)
            .with(date)
            .and_return(expenses)
        end

        it 'returns an empty array as JSON' do
          get "/expenses/#{date}"

          expect(response).to eq(expenses)
        end
        it 'responds with a 200 (OK)' do
          get "/expenses/#{date}"

          expect(last_response.status).to eq(200)
        end
      end
    end
  end
end
