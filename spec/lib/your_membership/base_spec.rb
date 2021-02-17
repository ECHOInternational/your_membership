require 'spec_helper'

module YourMembership
  RSpec.describe Base do
    describe '.post' do
      it 'uses YMXMLParser' do
        mock_parser = instance_double(
          ::HTTParty::YMXMLParser,
          parse: { 'YourMembership_Response' => { 'ErrCode' => 999 } }
        )
        allow(::HTTParty::YMXMLParser).to receive(:new).and_return(mock_parser)
        # It doesn't matter which cassette we use for this test.
        VCR.use_cassette 'sa_members_all_getids_timestamp_single' do
          response = described_class.post('/')
          expect(response).to be_an(::HTTParty::Response)
          expect(response['YourMembership_Response']).to eq('ErrCode' => 999)
        end
      end
    end
  end
end
