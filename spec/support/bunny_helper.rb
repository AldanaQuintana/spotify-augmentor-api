require 'as-duration'

module BunnyHelper
  def stub_bunny(stub_model = nil)
    @_bunny = stub_model || double('bunny').as_null_object

    allow(Bunny).to receive(:new).and_return(@_bunny)
  end

  def expect_message_to_be_published(message, routing_key)
    expect(@_bunny).to receive(:publish).with({message: message}.to_json, :routing_key => routing_key)
  end

  def expect_queue_to_be_created(name, *args)
    expect(@_bunny).to receive(:queue).with(name, *args).once
  end

  def expect_message_to_be_delayed(from, delay, message)
    delay_in_ms = delay.to_i
    delayed_queue_name = "send.later.queued_at_#{from}.process_at_#{from + (delay_in_ms / 1000).seconds}"

    expect_queue_to_be_created(delayed_queue_name, :arguments => { 
      "x-dead-letter-exchange" => "",
      'x-dead-letter-routing-key' => "batch_process",
      "x-message-ttl" => delay_in_ms,
      "x-expires" => delay_in_ms + 100
    })
    expect_message_to_be_published(message, delayed_queue_name)
  end
end