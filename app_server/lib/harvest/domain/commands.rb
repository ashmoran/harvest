module Harvest
  module Domain
    Commands = Realm::Messaging::MessageFactory.new do |commands|
      commands.define(:sign_up_fisherman,
        properties: {
          username:       String,
          email_address:  String,
          password:       String
        },
        responses: [
          :fishing_application_succeeded,
          :fishing_application_conflicts,
          :fishing_application_invalid
        ]
      )
    end

    Responses = Realm::Messaging::MessageFactory.new do |responses|
      responses.define(:fishing_application_succeeded,
        properties: { uuid: UUIDTools::UUID }
      )

      responses.define(:fishing_application_conflicts,
        properties: { message: String }
      )

      responses.define(:fishing_application_invalid,
        properties: { message: String }
      )
    end
  end
end