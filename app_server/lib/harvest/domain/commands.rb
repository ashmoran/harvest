module Harvest
  module Domain
    Commands = Realm::Messaging::MessageFactory.new do |commands|
      commands.define(:sign_up_fisherman, :username, :email_address, :password)
    end
  end
end