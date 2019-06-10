require 'spec_helper'

describe 'get top 10 tracks' do
	let!(:now){ Time.strptime('2019-04-01', '%Y-%m-%d') }

	before(:each) do
		insert_documents!
	end

	context 'when no time reference is specified' do
		before(:each) do
			Timecop.freeze(now) do
				get '/top-10'
			end
		end

		it 'returns ok' do
			expect(last_response.status).to eq(200)
		end

		it 'returns the most recent top 10' do
			expect(json_response.top_10).to be_a(Hash)
			expect(json_response.top_10['tracks'].size).to eq(10)
			expect(equal_dates(Time.parse(json_response.top_10['from']), now - 15.minutes)).to be(true)
			expect(equal_dates(Time.parse(json_response.top_10['to']), now)).to be(true)
		end
	end

	context 'when a time reference is specified' do
		before(:each) do
			Timecop.freeze(now) do
				get "/top-10?at=#{time.strftime('%FT%T')}"
			end
		end

		context 'and there are results for that time' do
			let(:time){ now - 20.minutes }


			it 'returns the top 10 from the period that includes that time' do
				expect(equal_dates(Time.parse(json_response.top_10['from']), now - 30.minutes)).to be(true)
				expect(equal_dates(Time.parse(json_response.top_10['to']), now - 15.minutes)).to be(true)
			end
		end

		context 'and there are no results for that time' do
			let(:time){ now + 1.minute }

			it 'returns the last available result' do
				expect(equal_dates(Time.parse(json_response.top_10['from']), now - 15.minutes)).to be(true)
				expect(equal_dates(Time.parse(json_response.top_10['to']), now)).to be(true)
			end
		end
	end

	def insert_documents!
		entries = [
			{ '_id' => '68mzU8iAvNnF3PCidY66K0', 'play_count' => 10 },
			{ '_id' => '51ChrwmUPDJvedPQnIU8Ls', 'play_count' => 9 },
			{ '_id' => '1YCUhR9OaaviHaVngMc7Ui', 'play_count' => 8 },
			{ '_id' => '0bVtevEgtDIeRjCJbK3Lmv', 'play_count' => 7 },
			{ '_id' => '27wbXcZKmqNV85Iz0SIJpI', 'play_count' => 6 },
			{ '_id' => '15e7BGo5XAH2gnEFaw5XAe', 'play_count' => 5 },
			{ '_id' => '33AxY0QUitvte6JV6B6uLE', 'play_count' => 4 },
			{ '_id' => '1Qdnvn4XlmZANCVy3XjrQo', 'play_count' => 3 },
			{ '_id' => '50kpGaPAhYJ3sGmk6vplg0', 'play_count' => 2 },
			{ '_id' => '3RJeEv9n8dP55yeHucEMxB', 'play_count' => 1 }
		]

		insert_top_10(entries, { from: now - 30.minutes, to: now - 15.minutes })
		insert_top_10(entries, { from: now - 15.minutes, to: now })
	end
end