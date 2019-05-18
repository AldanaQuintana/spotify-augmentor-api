require 'spec_helper'

describe 'startup' do
	describe 'getting ping' do
		before do
			get '/ping'
		end

		it do
			expect(last_response).to be_ok
			expect(last_response.body).to eq('pong')
		end
	end
end