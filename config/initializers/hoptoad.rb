# HoptoadNotifier.configure do |config|
#   config.api_key = 'b5f17df62b38157581e8152a6397e9a8'
#   
#   
# end

HoptoadNotifier.configure do |config|
  config.api_key = { :project => 'billedid',         # the identifier you specified for your project in Redmine
                    :tracker => 'Investigation',          # the name of your Tracker of choice in Redmine
                    :api_key => '9PZN6TqQrZoCoj0BXTsG',   # the key you generated before in Redmine (NOT YOUR HOPTOAD API KEY!)
                    :category => 'Development',           # the name of a ticket category (optional)
                    :assigned_to => 'peter',              # the login of a user the ticket should get assigned to by default (optional)
                    :priority => 5                        # the default priority (use a number, not a name. optional)
  }.to_yaml
  config.host = 'redmine.commanigy.com'            # the hostname your Redmine runs at
  config.port = 80                         # the port your Redmine runs at    
end