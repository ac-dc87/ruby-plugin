require 'ruby/plugin/utils/message_handler'

RSpec.describe Ruby::Plugin::Utils::MessageHandler do
  before do
    $config = {
      error_queue: 'some_error_queue'
    }
  end

  let(:rabbitmq_message) do
    {
      'sourceBean' => {
        'requestPath' => '/nextrials.cprism?action=send_form_event',
        'requestMethod' => verb
      },
      'message' => request_body.to_json
    }
  end
  let(:rabbitmq_props) do
    {
      content_type: 'application/json',
      content_encoding: 'UTF-8',
      headers: { '__TypeId__' => 'com.prahs.esource.jms.models.CustomJms' },
      delivery_mode: 2,
      priority: 0,
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
end
