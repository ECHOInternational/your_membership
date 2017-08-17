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

  it 'handle blank body response' do
    VCR.use_cassette 'no_body_response' do
      # Note that a nil body is unlikely (never) to occur within YM, but other non-YM tools may respond with a nil body
      response = HTTParty.post("https://api.yourmembership.com/")
      expect(response.body).to be nil
    end
  end
end
