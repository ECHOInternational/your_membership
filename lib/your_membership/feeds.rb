module YourMembership
  # YourMembership Feeds Namespace
  class Feeds < YourMembership::Base
    # Returns a list of RSS 2.0 community feeds.
    #
    # @see https://api.yourmembership.com/reference/2_00/Feeds_Get.htm
    #
    # @param [YourMembership::Session] session
    # @return [Array] Returns an Array of Hashes representing all of your community's feeds.
    def self.get(session)
      response = post('/', :body => build_XML_request('Feeds.Get', session))

      response_valid? response
      response_to_array_of_hashes response['YourMembership_Response']['Feeds.Get'], ['Feed']
    end

    # Returns a RSS 2.0 community feed
    #
    # @see https://api.yourmembership.com/reference/2_00/Feeds_Feed_Get.htm
    #
    # @param [YourMembership::Session] session
    # @param [String] feed_id ID of the Feed to be returned.
    # @param [Hash] options
    # @option options [Integer] :PageSize The maximum number of records in the returned result set.
    # @option options [Integer] :StartRecord The record number at which to start the returned result set.
    # @return [Nokogiri::XML] Returns a Nokogiri XML document that represents an rss feed
    def self.feed_get(session, feed_id, options = {})
      options[:FeedID] = feed_id

      response = post('/', :body => build_XML_request('Feeds.Feed.Get', session, options))

      response_valid? response
      xml_body = Nokogiri::XML response.body
      xml_body.at_xpath '//rss'
    end
  end
end
