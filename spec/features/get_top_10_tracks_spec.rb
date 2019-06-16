require 'spec_helper'
require 'spotify'

describe 'get top 10 tracks' do
	let!(:now){ Time.strptime('2019-04-01', '%Y-%m-%d') }

	before(:each) do
		insert_documents!
		mock_spotify_call!
	end

	describe 'the response' do
		let(:tracks) { json_response.top_10['tracks'] }
		before(:each) do
			Timecop.freeze(now) do
				get '/top-10'
			end
		end

		it 'includes the id' do
			expect(tracks[0]['id']).to eq('68mzU8iAvNnF3PCidY66K0')
		end

		it 'includes the play_count' do
			expect(tracks[0]['play_count']).to eq(10)
		end

		it 'includes the song name' do
			expect(tracks[0]['name']).to eq('Is this love')
		end

		it 'includes the artist name' do
			expect(tracks[0]['artist']).to eq('Sye Elaine Spence')		
		end
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
		mock_spotify_call!
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

	def mock_spotify_call!
		allow(Spotify).to receive(:get_track).with('68mzU8iAvNnF3PCidY66K0').and_return({"name" => "Is this love", "artists" => [{"name" => "Sye Elaine Spence"}]})
		allow(Spotify).to receive(:get_track).with('51ChrwmUPDJvedPQnIU8Ls').and_return({"name" => "Dive", "artists" => [{"name" => "Ed Sheeran"}]})
		allow(Spotify).to receive(:get_track).with('1YCUhR9OaaviHaVngMc7Ui').and_return({"name" => "Dreamboat Annie (Fantasy Child)", "artists" => [{"name" => "Heart"}]})
		allow(Spotify).to receive(:get_track).with('0bVtevEgtDIeRjCJbK3Lmv').and_return({"name" => "Welcome to the Jungle", "artists" => [{"name" => "Guns N' Roses"}]})
		allow(Spotify).to receive(:get_track).with('27wbXcZKmqNV85Iz0SIJpI').and_return({"name" => "Highway Tune", "artists" => [{"name" => "Greta Van Fleet"}]})
		allow(Spotify).to receive(:get_track).with('15e7BGo5XAH2gnEFaw5XAe').and_return({"name" => "Meet On The Ledge", "artists" => [{"name" => "Greta Van Fleet"}]})
		allow(Spotify).to receive(:get_track).with('33AxY0QUitvte6JV6B6uLE').and_return({"name" => "Gasoline", "artists" => [{"name" => "Audioslave"}]})
		allow(Spotify).to receive(:get_track).with('1Qdnvn4XlmZANCVy3XjrQo').and_return({"name" => "Show me how to live", "artists" => [{"name" => "Audioslave"}]})
		allow(Spotify).to receive(:get_track).with('50kpGaPAhYJ3sGmk6vplg0').and_return({"name" => "Love yourself", "artists" => [{"name" => "Justin Bieber"}]})
		allow(Spotify).to receive(:get_track).with('3RJeEv9n8dP55yeHucEMxB').and_return({"name" => "Black Hole Sun", "artists" => [{"name" => "Scott Bradlee's Postmodern Jukebox"}]})
	end
end