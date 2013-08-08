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

    signUp: (uri, details) ->
      deferred = RSVP.defer()

      @$.ajax
        url:      uri
        type:     'POST'
        dataType: 'json'
        data:     JSON.stringify(details)
        success: (data, textStatus, xhr) ->
          deferred.resolve(true)
        error: (xhr, textStatus, error) ->
          deferred.resolve(false)

      deferred.promise

  constructor: (dependencies) ->
    @httpClient = new HTTPClient(dependencies.jQuery)

    # We really don't want these URIs squirrelled away in here,
    # whatever happened to hypermedia?
    @signupURI            = "/api/fisherman-registrar"
    @usernameQueryURI     = "/api/username/"
    @emailAddressQueryURI = "/api/email_address/"

  signUp: (details) ->
    @httpClient.signUp(@signupURI, details)

  isUsernameAvailable: (desiredUsername) ->
    @httpClient.queryForIdentifierAvailability(@usernameQueryURI, desiredUsername)

  isEmailAddressAvailable: (desiredEmailAddress) ->
    @httpClient.queryForIdentifierAvailability(@emailAddressQueryURI, desiredEmailAddress)

root = global ? window
root.SignupService = SignupService
