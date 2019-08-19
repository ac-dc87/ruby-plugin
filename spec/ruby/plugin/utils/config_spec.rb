require 'ruby/plugin/utils/config'

RSpec.describe Ruby::Plugin::Utils::Config do
  subject { Ruby::Plugin::Utils::Config.validate_configuration }

  describe 'application configuration validation' do
    context 'AMQP_URL empty string' do
      before { stub_const('ENV', 'AMQP_URL' => '') }

      it 'prevents application from running without AMQP_URL' do
        expect { subject }.to raise_error(RuntimeError, 'Environment variable AMQP_URL needs to be set')
      end
    end

    context 'AMQP_URL empty string' do
      before { stub_const('ENV', 'AMQP_URL' => nil) }

      it 'prevents application from running without AMQP_URL' do
        expect { subject }.to raise_error(RuntimeError, 'Environment variable AMQP_URL needs to be set')
      end
    end

    context 'Default values' do
      before do
        stub_const('ENV', {
          'INTEGRATION' => 'rave_edc',
          'AMQP_URL' => 'some value',
          'INTEGRATION_QUEUE_NAME' => 'lala_queue',
          'LOG_FILE' => 'sneakers.log'
          }
        )
        stub_const('Ruby::Plugin::INTEGRATIONS', {
          'rave_edc' => {
            klass: Ruby::Plugin::Integrations::PrismEdc
          }
        })
      end
      it 'sets correct configuration values' do
        subject
        expect(subject).to eq(
          {
            amqp_url: 'some value',
            consumer_threads: 10,
            consumer_workers: 3,
            log_output: 'sneakers.log',
            integration: {
              klass: Ruby::Plugin::Integrations::PrismEdc
            },
            error_queue: 'Toolkit.Error',
            mapping: {}
          }
        )
      end
    end
  end

  describe 'integration configuration validation' do
    context 'INTEGRATION' do
      before do
        stub_const('ENV', {
          'INTEGRATION' => '',
          'AMQP_URL' => 'some value'
          }
        )
        stub_const('Ruby::Plugin::INTEGRATIONS', {
          'integration_a' => nil,
          'integration_b' => nil
        })
      end
      it 'prevents app from running and informs about possible integrations' do
        expect { subject }.to raise_error(RuntimeError, /Environment variable INTEGRATION needs to be set/)
        expect { subject }.to raise_error(RuntimeError, /Possible values are \["integration_a", "integration_b"\]/)
      end
    end

    context 'Mandatory integration config_keys' do
      before do
        stub_const('ENV', {
          'INTEGRATION' => 'rave_edc',
          'AMQP_URL' => 'some value'
          }
        )
        stub_const('Ruby::Plugin::INTEGRATIONS', 'rave_edc' => {
          config_keys: %w[a_key b_key]
        })
      end

      it 'prevents app from running config_keys are not set' do
        expect { subject }.to raise_error(RuntimeError, /Please set the following environment variables:/)
        expect { subject }.to raise_error(RuntimeError, /A_KEY, B_KEY/)
      end
    end

    context 'Missing INTEGRATION_QUEUE_NAME' do
      before do
        stub_const('ENV', {
          'INTEGRATION' => 'rave_edc',
          'AMQP_URL' => 'some value'
          }
        )
        stub_const('Ruby::Plugin::INTEGRATIONS', {
          'rave_edc' => {
            klass: Ruby::Plugin::Integrations::PrismEdc
          }
        })
      end

      it 'prevents app from running when queue_name is not set' do
        expect { subject }.to raise_error(RuntimeError, 'Environment variable INTEGRATION_QUEUE_NAME needs to be set')
      end
    end
  end
end
