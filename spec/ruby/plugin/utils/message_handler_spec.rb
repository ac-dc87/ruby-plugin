require 'ruby/plugin/utils/message_handler'

RSpec.describe Ruby::Plugin::Utils::MessageHandler do
  let(:fake_integration) { double('FakeIntegration', call: []) }

  before do
    $config = {
      integration: {
        klass: fake_integration
      }
    }
  end

  shared_examples 'correct payload for underlying service' do
    before do
      allow(fake_integration)
        .to receive(:call)
        .with(request)
    end

    it 'integration service called with correct payload' do
      subject
      expect(fake_integration).to have_received(:call).once
    end
  end

  # Both outer body and inner message have to be converted to the JSON.
  # That is how the toolkit is constructing the call
  let(:rabbitmq_message) do
    {
      'sourceBean' => {
        'requestPath' => '/nextrials.cprism?action=send_form_event',
        'requestMethod' => verb
      },
      'message' => request_body.to_json
    }.to_json
  end
  let(:rabbitmq_props) do
    {
      content_type: 'application/json',
      reply_to: 'Toolkit.String',
      message_id: '5655ff26-f29b-4e5a-be22-15461b03d067'
    }
  end

  shared_context 'POST request' do
    let(:verb) { 'POST' }
    let(:request_body) do
      {
        'formId': '3152221004',
        'formFields': {
          'meal_time': '04:51'
        }
      }
    end
  end

  shared_context 'GET request' do
    let(:verb) { 'GET' }
    let(:request_body) { nil }
  end

  let(:verb) { nil }
  let(:request_body) { nil }

  subject { Ruby::Plugin::Utils::MessageHandler.new(rabbitmq_message, rabbitmq_props).handle }

  describe '.handle' do
    context 'GET request' do
      include_context 'GET request'
      let(:request) do
        {
          message_properties: {
            content_type: 'application/json',
            reply_to: 'Toolkit.String',
            message_id: '5655ff26-f29b-4e5a-be22-15461b03d067'
          },
          action: 'send_form_event',
          verb: 'GET',
          body: {}
        }
      end
      it_behaves_like 'correct payload for underlying service'
    end

    context 'POST request' do
      include_context 'POST request'

      let(:request) do
        {
          message_properties: {
            content_type: 'application/json',
            reply_to: 'Toolkit.String',
            message_id: '5655ff26-f29b-4e5a-be22-15461b03d067'
          },
          action: 'send_form_event',
          verb: 'POST',
          body: {
            'formFields' => {
              'meal_time' => '04:51'
            },
            'formId' => '3152221004'
          }
        }
      end
      it_behaves_like 'correct payload for underlying service'
    end
  end
end
