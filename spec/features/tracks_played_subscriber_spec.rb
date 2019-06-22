require 'spec_helper'
require 'queue/queue_subscriber'

describe QueueSubscriber::TracksPlayed do
	let(:before_processing_execute) { nil }
	let(:subscriber) { QueueSubscriber::TracksPlayed.new }

	describe 'when a tracks.played message is processed' do
		let!(:before_timestamp) { Time.now - 1000 }
		let!(:now_timestamp) { Time.now }
		let(:user_id_1) { 1234 }
		let(:track_id_1) { '0bVtevEgtDIeRjCJbK3Lmv' }
		let(:msg) do
			{
				message: {
					tracks: [
						{
							track_id: track_id_1,
							user_id: user_id_1,
							timestamp: now_timestamp
						}
					]
				}
			}.to_json
		end

		before(:each) do
			Timecop.freeze(now_timestamp) do
				execute_before_processing!
				subscriber.work(msg)
			end
		end

		it 'saves it to the database' do
			expect(tracks_played_collection.find({}).count).to eq(1)
		end

		it 'saves it with the right format' do
			expect(saved_track_entry[:track_id]).to eq(track_id_1)
			expect(saved_track_entry[:user_id]).to eq(user_id_1)
			expect(
				equal_dates(
					saved_track_entry[:timestamp], 
					now_timestamp
				)
			).to be(true)
		end

		context 'the entry for that track id already existed' do
			let(:before_processing_execute) do
				lambda { insert_track(track_id_1, user_id_1, before_timestamp) }
			end		

			context 'and it is from the same user' do
				let(:before_processing_execute) do
					lambda { 
						insert_track(
							track_id_1, user_id_1, before_timestamp
						) 
					}
				end	

				it 'doesn\'t save it again' do
					expect(tracks_played_collection.find({}).count).to eq(1)
				end

				it 'updates the timestamp' do
					expect(
						equal_dates(
							saved_track_entry[:timestamp], 
							now_timestamp
						)
					).to be(true)
				end				
			end

			context 'and it is from another user' do
				let(:another_user_id) { "anotheruserid" }
				let(:before_processing_execute) do
					lambda { 
						insert_track(
							track_id_1, another_user_id, before_timestamp
						) 
					}
				end

				it 'inserts it' do
					expect(saved_track_entries.count).to eq(2)
					expect(saved_track_entries.find({user_id: user_id_1})).not_to be_nil
				end
			end
		end
	end

	def execute_before_processing!
		return if before_processing_execute.nil?
		before_processing_execute.call
	end
end