require 'spec_helper'

describe 'FixCdata' do
  it 'string returned' do
    VCR.use_cassette 'sa_members_all_getids_timestamp_single' do
      response = HTTParty.post("https://api.yourmembership.com/")
      expect(response.body).to be_a(String)
    end
  end

  it 'replace &lt;![CDATA' do
    VCR.use_cassette 'sa_members_cdata' do
      response = HTTParty.post("https://api.yourmembership.com/")
      expect(response.body).to include("<![CDATA[")
    end
  end

  it 'replace ]]&gt' do
    VCR.use_cassette 'sa_members_cdata' do
      response = HTTParty.post("https://api.yourmembership.com/")
      expect(response.body).to include("]]>")
    end
  end

  it 'handle nil body response' do
    VCR.use_cassette 'no_body_response' do
      # The `null` in the cassette is being turned into a body of "" instead of a nil body. Stub it to be nil.
      expect_any_instance_of(HTTParty::Response).to receive_messages(body: nil)
      # Note that a nil body is unlikely (never) to occur within YM, but other non-YM APIs may respond with a nil body,
      # so we need to ensure that our patch can handle that.
      response = HTTParty.post("https://api.yourmembership.com/")
      expect(response.body).to be nil
    end
  end
end
