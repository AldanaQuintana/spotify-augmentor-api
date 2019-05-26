require 'spec_helper'

describe 'get top 10 tracks' do
	describe 'fetching the top 10 tracks' do
		before(:each) do
			insert_documents!
			get '/top-10'
		end

		it 'returns ok' do
			expect(last_response.status).to eq(200)
		end

		it 'returns them' #TODO: pending test
	end

	def insert_documents!
		# TODO: insert top 10 documents
	end
end