require 'spec_helper'

describe Shoryuken::Symbolizer do

  it 'has a version number' do
    expect(Shoryuken::Symbolizer::VERSION).not_to be nil
  end

  it 'calls Shoryuken.configure_server when .register is called' do
    expect(Shoryuken).to receive(:configure_server)
    subject.register
  end

  context 'when a worker performs' do
    let(:manager)   { double Shoryuken::Manager, processor_done: nil }
    let(:queue) { 'default' }
    let(:sqs_queue) { double Shoryuken::Queue, visibility_timeout: 60 }

    let(:sqs_msg) do
      double Shoryuken::Message,
        queue_url: queue,
        body: {"json" => "valid"},
        message_id: 'fc754df7-9cc2-4c41-96ca-5996a44b771e'
    end

    before do
      allow(Shoryuken::Client).to receive(:queues).with(queue).and_return(sqs_queue)
    end

    it 'when body is a hash, use symbols' do
      # TestWorker.get_shoryuken_options['body_parser'] = :json
      TestWorker.get_shoryuken_options['body_parser'] = Class.new do
        def self.load(*args)
          JSON.load(*args)
        end
      end

      subject::Hook.new.call(TestWorker.new, queue, sqs_msg, sqs_msg.body) {}
    end

  end
end
