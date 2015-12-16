require 'spec_helper'

module YourMembership
  module Sa
    RSpec.describe Members do
      describe '.all_getIDs' do
        it 'returns an ID when there is only one member found' do
          VCR.use_cassette 'sa_members_all_getids_timestamp_single' do
            time = days_ago(10).strftime('%Y-%m-%d %H:%M:%S')
            result = described_class.all_getIDs(:Timestamp => time)
            expect(result).to be_a(String)
          end
        end

        it 'returns an array when there are multiple members found' do
          VCR.use_cassette 'sa_members_all_getids_timestamp_multiple' do
            time = days_ago(14).strftime('%Y-%m-%d %H:%M:%S')
            result = described_class.all_getIDs(:Timestamp => time)
            expect(result).to be_an(Array)
          end
        end

        it 'returns an empty array when there are no members found' do
          VCR.use_cassette 'sa_members_all_getids_timestamp_none' do
            time = days_ago(0).strftime('%Y-%m-%d %H:%M:%S')
            result = described_class.all_getIDs(:Timestamp => time)
            expect(result).to be_an(Array)
            expect(result).to eq([])
          end
        end
      end

      def days_ago(n)
        Time.now - n * 24 * 60 * 60
      end
    end
  end
end
