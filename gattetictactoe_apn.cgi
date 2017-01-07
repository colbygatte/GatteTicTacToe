#!/home/cpgprivate/.rvm/wrappers/ruby-1.9.3-p551/ruby

require 'apns'
require 'cgi'

APNS.pem = '/home/cpgprivate/GTCert.pem'
cgi = CGI.new
apnToken = cgi.params['apnToken'][0]
message = cgi.params['message'][0]

puts "Content-type: plain-text\n\n"

if !apnToken.empty? && !message.empty?
  notification = APNS::Notification.new(apnToken, message)

  APNS.send_notifications([notification])
end