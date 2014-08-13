YourMembership: Ruby SDK for the YourMembership.Com XML API
===========================================

_This SDK for Version 2.00 of the YourMembership.com API_

[![Gem Version](https://badge.fury.io/rb/your_membership.svg)](http://badge.fury.io/rb/your_membership)
[![Inline docs](http://inch-ci.org/github/ECHOInternational/your_membership.svg?branch=master)](http://rubydoc.info/gems/your_membership/1.0.0/frames)

## Installation

Add this line to your application's Gemfile:

    gem 'your_membership'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install your_membership

## Usage

Every effort has been made to expose the YourMembership.com API as transparently as possible while still providing a natively Ruby interface. 

### Scope and Naming

Everything is scoped under the `YourMembership` namespace.

Methods are named according to the naming conventions used in the API mapped to appropriate Ruby conventions:

	`Events.All.Search` becomes `YourMembership::Events.all_search`
	`Member.Commerce.Store.GetOrderIDs` becomes `YourMembership::Member.commerce_store_getOrderIDs`
	`Sa.Members.All.GetIDs` becomes `YourMembership::Sa::Members.all_getIDs`

Note that the dot `.` notation has been converted to Ruby's preferred all-lowercase underscore "snake" `_` conventions, but that the method name camelCasing has been preserved for all characters other than the first.

### Configuration

You can configure the gem in one of two ways:

#### YAML

Pass a YAML file through `YourMembership.configure_with(YourFilename.YAML)`

_Example YAML File_

```YAML
---
# Configuration settings for YourWebsiteHere.com
publicKey: 45G2E6DC-98NA-45W7-8493-D97C4E2C156A
privateKey: D74H44B2-2348-4ACT-B531-45W385TGB966
saPasscode: WPIkriJtqS4m
baseUri: 'https://api.yourmembership.com'
version: '2.00'
```

#### Configuration Hash

Pass in one or more parameters through a hash of configuration keys

_Example Configuration Hash_

```RUBY
YourMembership.configure :publicKey => 45G2E6DC-98NA-45W7-8493-D97C4E2C156A, :privateKey => D74H44B2-2348-4ACT-B531-45W385TGB966, :saPasscode => WPIkriJtqS4m
```

*Note that the baseUri and version are both defaulted to the current API for the release version.

### Method Arguments and Returned Value Types

#### Arguments

Method arguments marked as required in the YourMembership.com API must are implemented as required arguments to the SDK methods in this pattern:

`YourMembership::Namespace.some_methodName(sessionArgument, requiredArgument(s), optionsHash)`

The `sessionArgument` is required for most method calls in the API, but is sometimes not required. The ::Sa:: (System Administrator) namespaced methods usually do not require a session.

The options hash is present any time optional arguments can be passed to a method. These are sent as key-value pairs with the keys being `:symbol` objects named and cased in the way the API requires. For instance:

`YourMembership::Events.all_search` takes one required argument (a session object/key) and up to three optional arguments passed as a hash.

```RUBY
session = YourMembership::Session.new
options = {:SearchText => "A string to search for", :PageSize => 5, :StartRecord => 6}
YourMembership::Events.all_search session, options
```
**Note:** _Arguments passed as symbols need to be capitalized in the way that the API expects them. Many Rubyists prefer camelCased symbols, but in the case of the SDK you'll need to provide first-letter-capitalized CamelCase arguments._

You can pass strings as keys if you do not prefer to use Symbols.

##### SDK-Specific Implementation of Argument Types

You should use the standard Ruby types to represent data, for instance: 

`:Timestamp` and other date or time arguments should be passed as DateTime objects rather than formatted strings, the formatting will be done for you.

**A little added Syntactic Sugar:** Where a limited scope of static options is present some handy symbols have been added for convenience. For instance:

`YourMembership::Member.commerce_store_getOrderIDs` takes an optional `:Timestamp` argument (which should be passed as a Ruby `DateTime` object) and an optional `:Status` argument. The `:Status` argument can either be an integer that represents a status as documented in the API or you can use a symbol that will automatically be mapped through a helper method. In this case you can pass `:open`, `:processed`, `:shipped`, `:closed`, or `:cancelled`.

#### Returned Values

The SDK translates the returned data into Ruby Objects of only a few types. Nearly all methods return an Array, this may be an Array of Strings or, more likely, it will be an Array of Hashes. 

If only a single record can ever be retrieved at a time through a method a Hash object will be returned instead of an Array.

In the case that multiple records could be returned, but no records are returned you should receive an empty Array.

The return type you should expect is documented along with every method in the source.

**Special Case:** The `YourMembership::Feeds.feed_get` method returns a Nokogiri::XML object

--------------------------------------------------------------------------------

### SDK Special Objects

The SDK implements some representative objects that provide convenience.

#### YourMembership::Session

**Note:** *It is important to note that the Auth Namespace has been consumed by Sessions in the SDK as sessions and authentication are inextricably linked.*

Session objects encapsulate the creation, storage, authentication, maintenance, and destruction of sessions in the YourMembership.com API.

Sessions can be **generic** (unauthenticated), **authenticated**, or **abandoned**.

+ **Generic sessions** are used extensively whenever the scope of a specific user is not necessary.
+ **Authenticated sessions** are used when the called method requires the scope of a specific user.
+ **Abandoned sessions** are no longer usable and are essentially the same as logging out. A session can be forcibly abandoned and is automatically considered abandoned if it is not used for more than 20 minutes. If a session is needed for a length of more than 20 minutes the `ping` method can be called to extend the life-cycle for another 20 minutes.

##### Examples:
```RUBY
# Generic (unauthenticated) Session
session = YourMembership::Session.new

# Authenticated Session
auth_session = YourMembership::Session.new 'username', 'password'

# Sessions can also be authenticated after creation in one of two ways:

# By providing Credentials
session.authenticate 'username', 'password'

# Or through Token Authentication
token = session.createToken
```

##### Additional Methods
These additional methods report on the status of the session on the YourMembership.com server.

+ `.valid?` indicates if a session is still _alive_ and able to be used to make calls
+ `.authenticated?` indicates if a session is authenticated

#### YourMembership::Member

The Member object builds upon the Session object to more fully represent an authenticated session and provide an easy way to encapsulate the Member methods within the session's authenticated scope.

##### Instantiation:
```RUBY
# Members can be created by authenticating directly with the YourMembership API,
# the session is automatically created and bound to the Member instance. 
member = YourMembership::Member.create_by_authentication 'username', 'password'

# Members can also be created by passing in an already existing Session instance
# this is especially useful when Sessions are authenticated through token
# authentication.
auth_session = YourMembership::Session.new 'username', 'password'
member = YourMembership::Member.create_from_session auth_session
```
_Member objects can be created directly without a bound Session, but there is (as of yet) very little use for this._

#### Making use of a Member Instance

When a Member object is instantiated some basic properties of the represented member are cached in the object:
+ id - The member's API ID String
+ website_id - The member's unique identifier within your community
+ first_name
+ last_name
+ email

These fields are useful in reducing the number of round trips to the API for some commonly used attributes, but the real benefit of the Member instance is to be able to access all of the Member namespaced methods within the scope of the member.

Any method in the Member Namespace can be called like these examples:
```RUBY
member = YourMembership::Member.create_by_authentication 'username', 'password'

profile = member.profile_get
sent_messages = member.messages_getSent
...
order = member.commerce_store_order_get member.commerce_store_getOrderIDs[0]
```
**NOTE:** *Of course all of the methods of the Member namespace can be called without a Member instance, but an authorized session will need to be passed as the first argument.*

##### Member Session Management:

The Member instance's bound Session instance is accessible as an attribute.

#### YourMembership::Profile

The Profile object provides a convenient abstraction that encapsulates a person's profile allowing clear and concise access to both the core fields provided by YourMembership and the custom fields added by site administrators.

The API has some required fields for new members so a specific method (Profile.create_new) exists for the convenience of quickly creating a new profile for a new person.

A profile can be loaded by passing a hash directly to the initializer (Profile.new) method. This can be useful in creating a profile object from an API response. This is how profile objects are created internally through the YourMembership::Member.profile_get, YourMembership::People.profile_get, and YourMembership::Sa::People.profile_get methods.

A profile can be created empty or by passing a hash for standard fields. This is useful for updating an existing profile without changing unnecessary records.

An *outdated* list of standard fields can be found here: https://api.yourmembership.com/reference/YM_API_Member_Field_Documentation.pdf

##### Data Access
+ **Profile#data** `Hash` This internal hash can be read and written to and should contain only fields that are standard in the YourMembership system.
+ **Profile#custom_data** `Hash` This internal hash can be read and written to and should contain the fields that are specified as custom responses in a specific YourMembership community. 
+ **Profile#to_h** `Hash` is a read-only method for returning a single nested hash of both standard and custom fields.

#### YourMembership::Export

Export objects are returned when any YourMembership::Sa::Export method is called. This provides an easy way to keep track of the status of the export request. Export requests are handled asynchronously and therefore should be polled until the results are ready.

The Export object provides the Export#status method. It is necessary to call the Export#status method at least once in the export objects lifecycle as the export_uri will not be made available until status is called.

**Example:**

```RUBY
donations = YourMembership::Sa::Export.donations_transactions(DateTime.now, True)

# Implement a loop to check status

case donations.status
when :failure, :error
	# Stop looping, the process failed
when :unknown, :working
	# Continue looping
when :complete
	# Export is ready
	donations.export_uri
end
``` 

## About The Author(s)

![ECHO Inc.](http://static.squarespace.com/static/516da119e4b00686219e2473/t/51e95357e4b0db0cdaadcb4d/1407936664333/?format=1500w)

This library is an open-source project built by ECHO, an international nonprofit working to help those who are teaching farmers around the world know how to be more effective in producing enough to meet the needs of their families and their communities. ECHO is an information hub for international development practitioners specifically focused on sustainable, small-scale, agriculture. Through educational programs, publications, and networking ECHO is sharing solutions from around the world that are solving hunger problems.

Charity Navigator ranks ECHO as the #1 International Charity in the state of Florida (where their US operations are based) and among the top 100 in the US.

Thanks to grants and donations from people like you, ECHO is able to connect trainers and farmers with valuable (and often hard-to-find) resources. One of ECHO's greatest resources is the network of development practitioners, around the globe, that share help and specialized knowledge with each other. ECHO uses the YourMembership product to help facilitate these connections.

To find out more about ECHO, or to help with the work that is being done worldwide please visit http://www.echonet.org

## Contributing

If you find a problem with this library or would like to contribute an improvement please fork and submit a pull request.

If you're a developer that would like to help solve world hunger problems with some of your spare time, we are always looking for talented volunteers. Contact Nate Flood by email: nate [at] echonet [dot] org

1. Fork it ( https://github.com/ECHOInternational/your_membership/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
