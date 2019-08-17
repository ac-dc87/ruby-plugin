require 'ruby/plugin/integrations/base'

RSpec.describe Ruby::Plugin::Integrations::Base do
  before do
    $config = {
      mapping: {
        'data' => {
          'mapping_a' => 'converted_mapping_a',
          'mapping_b' => 'converted_mapping_b',
          'mapping_c' => 'converted_mapping_c',
          'mapping_d' => 'converted_mapping_d'
        }
      }
    }
  end
  describe 'Base object creation' do
    let(:request) do
      {
        verb: 'POST',
        body: {
          'does_not_have_mapping' => '11',
          'mapping_a' => 'simple type',
          'does_not_have_mapping_2' => {
            'mapping_b' => '12:12',
            'does_not_have_mapping_3' => {
              'deeply_nested_no_mapping' => {
                'mapping_d' => 22
              }
            },
            'mapping_c' =>  '01 MAY 2019'
          }
        }
      }
    end

    let(:expected_body) do
      {
        'does_not_have_mapping' => '11',
        'converted_mapping_a' => 'simple type',
        'does_not_have_mapping_2' => {
          'converted_mapping_b' => '12:12',
          'does_not_have_mapping_3' => {
            'deeply_nested_no_mapping' => {
              'converted_mapping_d' => 22
            }
          },
          'converted_mapping_c' =>  '01 MAY 2019'
        }
      }
    end

    subject { Ruby::Plugin::Integrations::Base.new(request).data }

    it 'after object is created, keys converted (on any hash level) using mappings' do
      expect(subject).to eq(expected_body)
    end
  end
end
