require 'spec_helper'
require 'timecop'
require 'queue/message_delayer'

describe MessageDelayer do
	include BunnyHelper
	before(:each) do
		stub_bunny
	end

	describe 'deliver_async' do
		let(:now) { Time.now }

		context 'without delaying' do
			it do
				expect_message_to_be_published({}.to_json, "batch_process").once
				MessageDelayer.deliver_async({ message: {} })
			end
		end

		context 'delaying a top_10_since message' do
			let(:delay_in_ms){ 400 }

			it do
				expect_message_to_be_delayed(now, delay_in_ms, {
					period: {
						from: now,
						to: now + delay_in_ms
					}
				})

				Timecop.freeze(now) do
					MessageDelayer.deliver_async({message: {
						top_10_since: now
					}, delay: delay_in_ms })
				end
			end
		end
	end
end