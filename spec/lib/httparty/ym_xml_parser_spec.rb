require 'spec_helper'

module HTTParty
  RSpec.describe YMXMLParser do
    it 'decodes HTML entities, eg. less-than, greater-than signs' do
      body = <<~XML
        <?xml version="1.0" encoding="utf-8" ?>
        <YourMembership_Response>
          <ErrCode>0</ErrCode>
          <ExtendedErrorInfo>&lt;![CDATA[Text information here]]&gt;</ExtendedErrorInfo>
          <Sa.Members.All.GetIDs>
          <ServerGmtBias>-5</ServerGmtBias>
          <ServerTime>2015-12-16 15:54:12</ServerTime>
          <Members>
            <ID>57EEB598-CB44-4D85-B0D6-377F393AF5B4</ID>
            <ID>1C0CE647-FAA5-4EB0-ADF0-5B669B36378E</ID>
          </Members>
          </Sa.Members.All.GetIDs>
        </YourMembership_Response>
      XML
      parser = described_class.new(body, :xml)
      parsed = parser.parse
      expect(parsed).to be_a(Hash)
      ymr = parsed['YourMembership_Response']
      expect(ymr['ErrCode']).to eq('0')
      expect(ymr['ExtendedErrorInfo']).to eq('Text information here')
    end
  end
end
