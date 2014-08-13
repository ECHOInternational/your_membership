require "httparty"
require "nokogiri"
require "yaml"

require "httparty/patch"

require "your_membership/error"
require "your_membership/config"
require "your_membership/base"
require "your_membership/session"
require "your_membership/profile"
require "your_membership/member"
require "your_membership/commerce"
require "your_membership/members"
require "your_membership/convert"
require "your_membership/sa_auth"
require "your_membership/sa_members"
require "your_membership/sa_certifications"
require "your_membership/sa_commerce"
require "your_membership/sa_events"
require "your_membership/sa_export"
require "your_membership/sa_groups"
require "your_membership/sa_member"
require "your_membership/sa_nonmembers"
require "your_membership/sa_people"
require "your_membership/events"
require "your_membership/feeds"
require "your_membership/people"

require "your_membership/version"

# Ruby SDK for YourMembership.Com XML API
# @author Nate Flood <nflood@echonet.org>
# @version 2.00
# @see http://www.yourmembership.com/company/api-reference.aspx
module YourMembership
end
