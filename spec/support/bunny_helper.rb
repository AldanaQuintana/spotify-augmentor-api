module BunnyHelper
  def stub_bunny(stub_model = nil)
    @_bunny = stub_model || double('bunny').as_null_object

    allow(Bunny).to receive(:new).and_return(@_bunny)
  end

  def expect_message_to_be_published(message, routing_key)
    expect(@_bunny).to receive(:publish).with(message, :routing_key => routing_key)
  end

  def expect_queue_to_be_created(name, *args)
    expect(@_bunny).to receive(:queue).with(name, *args).once
  end
end