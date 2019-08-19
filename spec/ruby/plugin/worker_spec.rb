require 'ruby/plugin'
require 'ruby/plugin/worker'

RSpec.describe Ruby::Plugin::Worker do
  before do
    $config = {
      error_queue: 'some_error_queue'
    }
  end

  let(:rabbitmq_props) do
    {
      reply_to: 'Toolkit.String',
      message_id: '5655ff26-f29b-4e5a-be22-15461b03d067'
    }
  end

  describe 'work_with_params', :fake_publisher do
    subject { Ruby::Plugin::Worker.new.work_with_params({}, nil, rabbitmq_props) }

    context 'Something unpredicted happened in MessageHandler' do
      let(:unpredicted_error) { 'Something went horribly wrong' }
      before do
        allow(Ruby::Plugin::Utils::MessageHandler)
          .to receive(:handle).with({}, rabbitmq_props)
          .and_raise(
            Ruby::Plugin::CustomProcessingResponseException.new(
              unpredicted_error,
              'UNPROCESSABLE_ENTITY'
            )
          )
      end

      it 'sends error message to the broker on the correct queue' do
        subject
        expect(Sneakers::Testing.messages_by_queue['some_error_queue'].first)
          .to match(/#{unpredicted_error}/)
      end
    end

    context 'All went well' do
      let(:response_object) { { 'a' => 'b' } }
      before do
        allow(Ruby::Plugin::Utils::MessageHandler)
          .to receive(:handle).with({}, rabbitmq_props)
          .and_return(response_object)
      end

      it 'sends payload message (in JSON format) to the broker on the correct queue' do
        subject
        queue_message = JSON.parse(Sneakers::Testing.messages_by_queue['Toolkit.String'].first)
        expect(queue_message).to eq(response_object)
      end
    end
  end
end
