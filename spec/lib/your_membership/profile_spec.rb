require "spec_helper"

describe YourMembership::Profile do
  before do
    @sample_profile = {
      "ID"=>"F8C2BEFD-GF37-5CBC-B750-487162B95CDF",
      "WebsiteID"=>"16273406",
      "PrimaryGroupCode"=>nil,
      "IsMember"=>"1",
      "IsNonMember"=>"0",
      "Registered"=>"2014-06-12 14:53:30",
      "LastUpdated"=>"2014-08-07 14:31:34",
      "ImportID"=>"YM-40539-798958-4242",
      "ConstituentID"=>nil,
      "EmailAddr"=>"nflood@echonet.org",
      "EmailBounced"=>"0",
      "NamePrefix"=>"Mr",
      "FirstName"=>"Nate",
      "MiddleName"=>nil,
      "LastName"=>"Flood",
      "NameSuffix"=>nil,
      "Nickname"=>"Nate Flood",
      "Gender"=>"M",
      "Birthdate"=>nil,
      "MaritalStatus"=>nil,
      "MaidenName"=>nil,
      "SpouseName"=>nil,
      "AnniversaryDate"=>nil,
      "Employer"=>"ECHO INC.",
      "Title"=>"Digital Media Specialist",
      "Profession"=>nil,
      "Membership"=>"ECHO Interns and Current Staff",
      "MembershipExpiry"=>nil,
      "MemberTypeCode"=>"ECHOstaff",
      "Approved"=>"1",
      "Suspended"=>"0",
      "Username"=>"nflood",
      "PasswordHash"=>"1E10A122BDB35AN022FEJF617BE14527E72KA26E",
      "AltEmailAddr"=>nil,
      "HomeAddrLines"=>nil,
      "HomeCity"=>nil,
      "HomeLocation"=>nil,
      "HomePostalCode"=>nil,
      "HomeCountry"=>nil,
      "Website"=>nil,
      "HomePhAreaCode"=>nil,
      "HomePhone"=>nil,
      "MobileAreaCode"=>nil,
      "Mobile"=>nil,
      "EmpAddrLines"=>"17391 Durrance Road",
      "EmpCity"=>"North Fort Myers",
      "EmpLocation"=>"Florida",
      "EmpPostalCode"=>"33917",
      "EmpCountry"=>"United States",
      "BusinessWebsite"=>nil,
      "EmpPhAreaCode"=>"239",
      "EmpPhone"=>"567-3355",
      "EmpFaxAreaCode"=>nil,
      "EmpFax"=>nil,
      "LastRenewalReminderSent"=>nil,
      "GamificationPoints"=>"198",
      "HeadshotImageURI"=>"http://c.yourmembership.com/sites/echocommunity.site-ym.com/photos/alumni/20140725_144857_16292.jpg",
      "MasterID"=>nil,
      "LastRenewalDate"=>"2014-06-12 14:53:00",
      "ApprovalDate"=>"6/12/2014 2:54:19 PM",
      "LastModifiedDate"=>"2014-08-07 14:31:34",
      "QueuedForDelete"=>"0",
      "QueuedForDeleteDate"=>nil,
      "Latitude"=>"0",
      "Longitude"=>"0",
      "CustomFieldResponses"=>{
        "CustomFieldResponse"=>[
          {"Values"=>{"Value"=>"USA"}, "FieldCode"=>"Workingcountry", "Visibility"=>""},
          {"Values"=>{"Value"=>"other"}, "FieldCode"=>"UserType", "Visibility"=>""},
          {"Values"=>{"Value"=>"North America"}, "FieldCode"=>"region", "Visibility"=>""},
          {"Values"=>{"Value"=>["North","South"]}, "FieldCode"=>"PCVenddate", "Visibility"=>""}        ]
      }
    }
  end
  it "accepts and sets required parameters for new profiles" do
    profile = YourMembership::Profile.create_new('afirstname', 'alastname', 'amembertypecode', 'aemail', 'ausername', 'apassword', {})
    profile.data['FirstName'].should == 'afirstname'
    profile.data['LastName'].should == 'alastname'
    profile.data['MemberTypeCode'].should == 'amembertypecode'
    profile.data['EmailAddr'].should == 'aemail'
    profile.data['Username'].should == 'ausername'
    profile.data['Password'].should == 'apassword'
  end

  it "adds arbitrary keys when creating new profiles" do
    profile_hash = {'foo' => 'bar'}
    profile = YourMembership::Profile.create_new('afirstname', 'alastname', 'amembertypecode', 'aemail', 'ausername', nil, profile_hash)
    profile.data.should include 'foo'
    profile.data['foo'].should == 'bar'
  end

  it "adds arbitrary custom keys when creating new profiles" do
    profile_hash = {
      'CustomFieldResponses' => {
        'CustomFieldResponse' => [{
          'FieldCode' => 'foo',
          'Values' => {
            'Value' => 'bar'
          }
        }]
      }
    }
    profile = YourMembership::Profile.create_new('afirstname', 'alastname', 'amembertypecode', 'aemail', 'ausername', nil, profile_hash)
    profile.custom_data.should include 'foo'
    profile.custom_data['foo'].should == 'bar'
  end

  it "creates an object based on a profile hash" do
    profile = YourMembership::Profile.new(@sample_profile)
    profile.data.should include 'FirstName'
  end

  it "adds arbitrary keys when creating based on a profile hash" do
    profile_hash = {'foo' => 'bar'}
    profile = YourMembership::Profile.new(profile_hash)
    profile.data.should include 'foo'
    profile.data['foo'].should == 'bar'
  end

  it "returns the output hash when asked" do
    profile_hash = {'foo' => 'bar'}
    profile = YourMembership::Profile.new(profile_hash)
    profile.to_h.should be_a(Hash)
    profile.to_h.should include 'foo'
  end

  it "does not return nil values in the output hash" do
    profile_hash = {'foo' => 'bar', 'far' => nil}
    profile = YourMembership::Profile.new(profile_hash)
    profile.to_h.should include 'foo'
    profile.to_h.should_not include 'far'
  end

  it "can be manipulated directly through the data attribute" do
    profile_hash = {'foo' => 'bar'}
    profile = YourMembership::Profile.new(profile_hash)
    expect {profile.data['foo'] = 'baz'}.to change{profile.data['foo']}.from('bar').to('baz')
  end

  it "has a custom_data attribute" do
    profile = YourMembership::Profile.new
    expect profile.should respond_to 'custom_data'
  end

  it "can be manipulated directly through the custom data attribute" do
    profile = YourMembership::Profile.new
    profile.custom_data['foo'] = 'bar'
    expect profile.custom_data.should include 'foo'
    expect profile.custom_data['foo'].should == 'bar'
    expect {profile.custom_data['foo'] = 'baz'}.to change{profile.custom_data['foo']}.from('bar').to('baz')
  end

  it "adds a 'CustomFieldResponses' key as a hash" do
    profile_hash = {'foo' => 'bar'}
    profile = YourMembership::Profile.new(profile_hash)
    expect profile.to_h.should include 'CustomFieldResponses'
    expect profile.to_h['CustomFieldResponses'].should be_a(Hash)
  end

  it "contains custom_data in the 'CustomFieldResponses' key hash" do
    profile = YourMembership::Profile.new
    profile.custom_data['foo'] = 'bar'
    expect profile.to_h['CustomFieldResponses'].should include 'foo'
    expect profile.to_h['CustomFieldResponses']['foo'].should == 'bar'
  end

  it "accepts strings as custom data" do
    profile = YourMembership::Profile.new
    profile.custom_data['foo'] = 'bar'
    expect profile.to_h['CustomFieldResponses']['foo'].should be_a(String)
  end

  it "accepts arrays as custom data" do
    profile = YourMembership::Profile.new
    profile.custom_data['foo'] = ['bar', 'bat', 'baz']
    expect profile.to_h['CustomFieldResponses']['foo'].should be_a(Array)
    expect profile.to_h['CustomFieldResponses']['foo'].should include 'baz'
  end

  it "does not contain nil keys in the 'CustomFieldResponses'" do
    profile = YourMembership::Profile.new
    profile.custom_data['foo'] = nil
    expect profile.to_h['CustomFieldResponses'].should_not include 'foo'
  end

  it "does not include 'CustomFieldResponses' in the data hash when creating from a profile hash" do
      profile = YourMembership::Profile.new(@sample_profile)
      profile.data.should_not include 'CustomFieldResponses'
  end

  it "puts 'CustomFieldResponses' into the custom_data hash when creating from a profile hash" do
    profile = YourMembership::Profile.new(@sample_profile)
    profile.custom_data.should include 'Workingcountry'
  end

  it "converts 'CustomFieldResponse' values to strings or arrays" do
    profile = YourMembership::Profile.new(@sample_profile)
    profile.custom_data.should include 'Workingcountry'
    profile.custom_data['Workingcountry'].should == "USA"
  end

  describe 'when there is a single CustomFieldResponse' do
    it 'parses correctly' do
      odd_data = @sample_profile.clone
      odd_data['CustomFieldResponses'] = {
        "CustomFieldResponse" => {
          "Values" => {
            "Value" => "None"
          },
          "FieldCode" => "Foundation",
          "Visibility" => ""
        }
      }
      profile = YourMembership::Profile.new(odd_data)
      expect(profile.custom_data['Foundation']).to eq('None')
    end
  end
end
