require 'ruby/plugin/integrations/rave_edc/request'
require 'json'

RSpec.describe Ruby::Plugin::Integrations::RaveEdc::Request do
  let(:request) { nil }
  before do
    stub_const(
      'ENV',
      {
        'RAVE_STUDY_OID' => 'Clinical 6 Testing (DEV)',
        'RAVE_BASE_URL' => 'https://pra.mdsol.com/RaveWebServices'
      }
    )

    # Mapping form items
    $config = {
      mapping: {
        'data' => {
          'site_id' => 'SITEID',
          'account_name' => 'SUBJID'
        }
      }
    }

    allow(SecureRandom).to receive(:uuid).and_return('b510b43f-1bac-4945-80b3-843852031b73')
  end
  subject { described_class.call(request) }

  describe '#submit_simple_form', :vcr do
    let(:request) do
      {
        action: 'submit_simple_form',
        verb: 'POST',
        body: {
          'form_items' => {
            'site_id' => '666666',
            'account_name' => '9996'
          }
        },
        original_payload: {},
        params: {
          'site_id' => '666666',
          'study_event' => 'SUBJECT',
          'form_id' => 'SUBJ',
          'subject_data_transaction_type' => 'Insert',
          'subject_id' => '9996'
        }
      }
    end

    context 'Submitting simple form successfully' do
      it 'returns IsTransactionSuccessful equal to 1' do
        expect(JSON.parse(subject).dig('Response', 'IsTransactionSuccessful')).to eq('1')
      end
    end

    context 'error case we need to handle (unkown, details to come from PrismEDC)' do
      skip
    end
  end
end
