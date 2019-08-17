require 'ruby/plugin/integrations/prism_edc'

RSpec.describe Ruby::Plugin::Integrations::PrismEdc do
  let(:request) { nil }
  before do
    # Simulating mapping not provided
    $config = {
      mapping: {
        'data' => {}
      }
    }
    Ruby::Plugin::Integrations::PrismEdc.base_uri 'https://esource.nextrials.com/esource-toolkit'
  end
  subject { described_class.call(request) }

  describe '#send_form_event', :vcr do
    let(:request) do
      {
        action: 'send_form_event',
        verb: 'POST',
        body: {
          'formAbstractId' => '3083372917',
          'formFields' => {
            "IT.109cdc9572cf3732a8024c1a69d06eff7bcc32a5" => "12:12",
            "IT.20f745f2240052fa6ae7b0631d3179a5ee6cd808" => "BREAKFAST",
            "IT.590f2722f3b1b05aa327654611621866d07e785f" =>  "01 MAY 2019"
          }
        },
        original_payload: {}
      }
    end
    context 'meal event' do
      it 'returns 200 OK (there is not a way to verify this from prism EDC API yet)' do
        expect(subject).to eq('OK')
      end
    end

    context 'error case we need to handle (unkown, details to come from PrismEDC)' do
      skip
    end
  end

  describe '#edit_event', :vcr do
    let(:request) do
      {
        action: 'edit_event',
        verb: 'POST',
        body: {
          'formId' => '3154341004',
          'formFields' => { 'IT.109cdc9572cf3732a8024c1a69d06eff7bcc32a5' => '10:25'}
        }
      }
    end

    context 'edit meal event' do
      it 'returns 200 OK (there is not a way to verify this from prism EDC API yet)' do
        expect(subject).to eq('OK')
      end
    end
  end
end
