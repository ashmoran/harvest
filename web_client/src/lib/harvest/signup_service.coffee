class SignupService
  # This code is more factored than the tests
  class HTTPClient
    constructor: (jQuery) ->
      @$ = jQuery

    queryForIdentifierAvailability: (uri, identifier) ->
      deferred = RSVP.defer()

      @$.ajax
        url:      uri + identifier
        type:     'GET'
        dataType: 'json'
        success: (data, textStatus, xhr) ->
          switch data.status
            when 'available'    then deferred.resolve(true)
            when 'unavailable'  then deferred.resolve(false)

        error: (xhr, textStatus, error) ->
          deferred.resolve(false)

      deferred.promise

  constructor: (dependencies) ->
    @httpClient = new HTTPClient(dependencies.jQuery)

    @signUpURI            = "/api/fisherman-registrar"
    @usernameQueryURI     = "/api/username/"
    @emailAddressQueryURI = "/api/email_address/"

  signUp: (details) ->
    @$.ajax
      url:      @signUpURI
      type:     'POST'
      dataType: 'json'
      data:     JSON.stringify(details)

  isUsernameAvailable: (desiredUsername) ->
    @httpClient.queryForIdentifierAvailability(@usernameQueryURI, desiredUsername)

  isEmailAddressAvailable: (desiredEmailAddress) ->
    @httpClient.queryForIdentifierAvailability(@emailAddressQueryURI, desiredEmailAddress)

root = global ? window
root.SignupService = SignupService
