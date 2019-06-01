require 'spec_helper'
require 'timecop'
require 'queue/message_delayer'

describe MessageDelayer do
	include BunnyHelper
	before(:each) do
		stub_bunny
	end

	describe 'deliver_async' do
		let(:from) { Time.now }
		let(:now) { Time.now }
		let(:message) do
			{
				top_10_since: from
			}
		end

		context 'without delaying' do
			it do
				expect_message_to_be_published(message.to_json, "batch_process").once
				MessageDelayer.deliver_async({ message: message })
			end
		end

		context 'delaying the message' do
			let(:delay_in_ms){ 400 }

			it do
				expect_message_to_be_delayed(now, delay_in_ms, message)

				Timecop.freeze(now) do
					MessageDelayer.deliver_async({message: message, delay: delay_in_ms })
				end
			end
		end
	end
end