module YourMembership
  # YourMembership Members Namespace
  class Members < YourMembership::Base
    # Returns a member's connection category list.
    #
    # @see https://api.yourmembership.com/reference/2_00/Members_Connections_Categories_Get.htm
    #
    # @param [YourMembership::Session] session
    # @param [String] member_id or ProfileID of the member's connections to get.
    # @return [Array] Returns an Array of Hashes representing a member's connection categories.
    # @note If you attempt to retrieve a member's connection category list and they have not assigned any connections to
    #  categories an execption of type 406 from YourMembership.com 'Method could not uniquely identify a record on which
    #  to operate' will be raised.
    def self.connections_categories_get(session, member_id)
      options = {}
      options[:ID] = member_id
      response = post('/', :body => build_XML_request('Members.Connections.Categories.Get', session, options))

      response_valid? response
      response_to_array_of_hashes response['YourMembership_Response']['Members.Connections.Categories.Get'], ['Category']
    end

    # Returns a member's connection list, optionally filtered by category. Returns a maximum of 100 records per request.
    #
    # @see https://api.yourmembership.com/reference/2_00/Members_Connections_Get.htm
    #
    # @param [YourMembership::Session] session
    # @param [String] member_id or ProfileID of the member's connections to get.
    # @param [Hash] options
    # @option options [Integer] :CategoryID Filter the returned results by connection category.
    # @option options [Integer] :PageSize The maximum number of records in the returned result set.
    # @option options [Integer] :StartRecord The record number at which to start the returned result set.
    # @return [Array] Returns an Array of Hashes representing a member's connections.
    def self.connections_get(session, member_id, options = {})
      options = {}
      options[:ID] = member_id
      response = post('/', :body => build_XML_request('Members.Connections.Get', session, options))

      response_valid? response
      response_to_array_of_hashes response['YourMembership_Response']['Members.Connections.Get'], ['Connection']
    end

    # Returns a member's media gallery album list. The returned list will include <AlbumID>-1</AlbumID> which is a
    # virtual album containing all of the member's media gallery items.
    #
    # @see https://api.yourmembership.com/reference/2_00/Members_MediaGallery_Albums_Get.htm
    #
    # @param [YourMembership::Session] session
    # @param [String] member_id or ProfileID of the member whose media gallery albums to return.
    # @return [Array] Returns an Array of Hashes representing a member's albums.
    # @note BUG NOTED - This method seems to raise an exception on every call saying that Method Call Failed one or more
    #  elements is missing or invalid
    # @todo Contact YourMembership.com dev team to see if we're doing this correctly.
    def self.mediaGallery_albums_get(session, member_id) # rubocop:disable Style/MethodName
      options = {}
      options[:ID] = member_id
      # puts build_XML_request('Members.MediaGallery.Albums.Get', session, options)
      response = post('/', :body => build_XML_request('Members.MediaGallery.Albums.Get', session, options))

      response_valid? response
      response_to_array_of_hashes response['YourMembership_Response']['Members.MediaGallery.Albums.Get'], ['Album']
    end

    # Returns a member's media gallery item list, optionally filtered by album. Returns a maximum of 100 records per
    # request.
    #
    # @see https://api.yourmembership.com/reference/2_00/Members_MediaGallery_Get.htm
    #
    # @param [YourMembership::Session] session
    # @param [String] member_id or ProfileID of the member whose media gallery to retrieve.
    # @param [Hash] options
    # @option options [String] :AlbumID Filter the returned results by media gallery album.
    # @option options [Integer] :PageSize The maximum number of records in the returned result set.
    # @option options [Integer] :StartRecord The record number at which to start the returned result set.
    # @return [Array] Returns an Array of Hashes representing a member's media items.
    # @note If you attempt to retrieve a member's gallery item list and they have no media an exception will be thrown
    #  of type 406 from YourMembership.com 'Method could not uniquely identify a record on which to operate'
    def self.mediaGallery_get(session, member_id, options = {}) # rubocop:disable Style/MethodName
      options = {}
      options[:ID] = member_id
      response = post('/', :body => build_XML_request('Members.MediaGallery.Get', session, options))

      response_valid? response
      response_to_array_of_hashes response['YourMembership_Response']['Members.MediaGallery.Get'], ['Item']
    end

    # Returns a single media gallery item.
    #
    # @see https://api.yourmembership.com/reference/2_00/Members_MediaGallery_Item_Get.htm
    #
    # @param [YourMembership::Session] session
    # @param [String] member_id or ProfileID of the member whose media gallery item to return.
    # @param [Integer] item_id of the media gallery item to return.
    # @return [Hash] Returns an Hash that represents a single media item.
    def self.mediaGallery_item_get(session, member_id, item_id) # rubocop:disable Style/MethodName
      options = {}
      options[:ID] = member_id
      options[:ItemID] = item_id
      response = post('/', :body => build_XML_request('Members.MediaGallery.Item.Get', session, options))

      response_valid? response
      response['YourMembership_Response']['Members.MediaGallery.Item.Get']
    end

    # Returns a member's wall.
    #
    # @see https://api.yourmembership.com/reference/2_00/Members_Wall_Get.htm
    #
    # @param [YourMembership::Session] session
    # @param [String] member_id ID or ProfileID of the member's wall to get.
    # @param [Hash] options
    # @option options [Integer] :PageSize The maximum number of records in the returned result set.
    # @option options [Integer] :StartRecord The record number at which to start the returned result set.
    # @return [Hash] Returns a Hash representing the requested user's wall.
    def self.wall_get(session, member_id, options = {})
      options = {}
      options[:ID] = member_id
      response = post('/', :body => build_XML_request('Members.Wall.Get', session, options))

      response_valid? response
      response['YourMembership_Response']['Members.Wall.Get']
    end
  end
end
