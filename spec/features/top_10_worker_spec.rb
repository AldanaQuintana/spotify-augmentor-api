require 'spec_helper'
require 'as-duration'
require 'timecop'
require 'queue/queue_subscriber'


describe QueueSubscriber::Top10Worker do
	include BunnyHelper
	let(:now) { Time.now }
	let(:before_processing_execute) { nil }
	let(:track_id_0){ '0bVtevEgtDIeRjCJbK3Lmv' }
	let(:user_id_1) { 1234 }
	let(:subscriber) { QueueSubscriber::Top10Worker.new }
	let(:before_period){ from - 10000 }
	let(:from) { Time.strptime('2019-04-01', '%Y-%m-%d') }
	let(:to) { Time.strptime('2019-04-05', '%Y-%m-%d') }
	let(:msg) do
		{
			message: {
				period: {
					from: from,
					to: to
				}
			}
		}.to_json
	end

	before(:each) do
		stub_bunny
	end

	it 'enqueues another message' do
		new_message_from = to + 1.second #TODO: Fix ugly hack (+ 1.second). I was having a problem with the date format
		delay_in_ms = 10.minutes.to_i * 1000
		expect_message_to_be_delayed(now, delay_in_ms, {
			period: {
				from: new_message_from,
				to: new_message_from + (delay_in_ms / 1000).seconds
			}
		})

		Timecop.freeze(now) do
			subscriber.work(msg)
		end
	end



	describe 'when a process.top_10 msg is processed' do
		before(:each) do
			insert_track(track_id_0, user_id_1, before_period) # Insert track outside period for every test
			execute_before_processing!
			subscriber.work(msg)
		end

		context 'and there are no tracks for that period of time' do
			it 'saves nothing' do
				expect(saved_top_10_entries.count).to eq(0)
			end
		end

		context 'and there are tracks for that period of time' do
			let(:in_period) { Time.strptime('2019-04-02', '%Y-%m-%d') }
			let(:track_id_1) { '68mzU8iAvNnF3PCidY66K0' }
			let(:track_id_2) { '51ChrwmUPDJvedPQnIU8Ls' }
			let(:track_id_3) { '1YCUhR9OaaviHaVngMc7Ui' }
			let(:track_id_4) { '2Cd9iWfcOpGDHLz6tVA3G4' }
			let(:track_id_5) { '27wbXcZKmqNV85Iz0SIJpI' }
			let(:track_id_6) { '15e7BGo5XAH2gnEFaw5XAe' }
			let(:track_id_7) { '33AxY0QUitvte6JV6B6uLE' }
			let(:track_id_8) { '1Qdnvn4XlmZANCVy3XjrQo' }
			let(:track_id_9) { '50kpGaPAhYJ3sGmk6vplg0' }
			let(:track_id_00) { '4jshdkf3082sdkjflkdsj9' }
			let(:outside_period) { in_period + 1.day }
			let(:insert_tracks!) do
				lambda {
					10.times{ |user_id| insert_track(track_id_0, user_id, in_period) }
					9.times{ |user_id| insert_track(track_id_1, user_id, in_period) }
					8.times{ |user_id| insert_track(track_id_2, user_id, in_period) }
					7.times{ |user_id| insert_track(track_id_3, user_id, in_period) }
					6.times{ |user_id| insert_track(track_id_4, user_id, in_period) }
					5.times{ |user_id| insert_track(track_id_5, user_id, in_period) }
					4.times{ |user_id| insert_track(track_id_6, user_id, in_period) }
					3.times{ |user_id| insert_track(track_id_7, user_id, in_period) }
					2.times{ |user_id| insert_track(track_id_8, user_id, in_period) }
					1.times{ |user_id| insert_track(track_id_9, user_id, in_period) }

					# Track not in period
					1.times{ |user_id| insert_track(track_id_00, user_id, outside_period) }
				}
			end
			let(:before_processing_execute){ insert_tracks! }

			it 'saves an entry on the top_10 collection' do
				expect(saved_top_10_entries.count).to eq(1)
			end

			it 'saves an entry with the right format' do
				expect(equal_dates(saved_top_10_entry[:from], from)).to be(true)
				expect(equal_dates(saved_top_10_entry[:to], to)).to be(true)
				expect(saved_top_10_entry[:tracks]).to be_an(Array)
			end

			it 'saves the top 10 tracks' do
				expect(saved_top_10_entry[:tracks].count).to eq(10)

				expect(saved_top_10_entry[:tracks][0][:id]).to eq(track_id_0)
				expect(saved_top_10_entry[:tracks][0][:play_count]).to eq(10)

				expect(saved_top_10_entry[:tracks][1][:id]).to eq(track_id_1)
				expect(saved_top_10_entry[:tracks][1][:play_count]).to eq(9)

				expect(saved_top_10_entry[:tracks][2][:id]).to eq(track_id_2)
				expect(saved_top_10_entry[:tracks][2][:play_count]).to eq(8)

				expect(saved_top_10_entry[:tracks][3][:id]).to eq(track_id_3)
				expect(saved_top_10_entry[:tracks][3][:play_count]).to eq(7)

				expect(saved_top_10_entry[:tracks][4][:id]).to eq(track_id_4)
				expect(saved_top_10_entry[:tracks][4][:play_count]).to eq(6)

				expect(saved_top_10_entry[:tracks][5][:id]).to eq(track_id_5)
				expect(saved_top_10_entry[:tracks][5][:play_count]).to eq(5)

				expect(saved_top_10_entry[:tracks][6][:id]).to eq(track_id_6)
				expect(saved_top_10_entry[:tracks][6][:play_count]).to eq(4)

				expect(saved_top_10_entry[:tracks][7][:id]).to eq(track_id_7)
				expect(saved_top_10_entry[:tracks][7][:play_count]).to eq(3)

				expect(saved_top_10_entry[:tracks][8][:id]).to eq(track_id_8)
				expect(saved_top_10_entry[:tracks][8][:play_count]).to eq(2)

				expect(saved_top_10_entry[:tracks][9][:id]).to eq(track_id_9)
				expect(saved_top_10_entry[:tracks][9][:play_count]).to eq(1)				
			end

			it 'removes them from the database' do
				expect(saved_track_entries.count).to eq(1)
			end

			context 'and some tracks have been played equal number of times' do
				let(:before_processing_execute) do
					lambda {
						insert_tracks!.call
						insert_track(track_id_1, 1, in_period)
						insert_track('track_played_once', 2, in_period)
					}
				end

				it 'only saves 10 track entries' do
					expect(saved_top_10_entry[:tracks].count).to eq(10)

					expect(saved_top_10_entry[:tracks][0][:id]).to eq(track_id_1)
					expect(saved_top_10_entry[:tracks][0][:play_count]).to eq(10)

					expect(saved_top_10_entry[:tracks][1][:id]).to eq(track_id_0)
					expect(saved_top_10_entry[:tracks][1][:play_count]).to eq(10)
				end
			end
		end
	end

	def execute_before_processing!
		return if before_processing_execute.nil?
		before_processing_execute.call
	end
end