class SignupService
  constructor: (dependencies) ->
    @$    = dependencies.jQuery

    @signUpURL        = "/api/fisherman-registrar"
    @usernameQueryURL = "/api/usernames/"

  signUp: (details) ->
    @$.ajax
      url:      @signUpURL
      type:     'POST'
      dataType: 'json'
      data:     JSON.stringify(details)

  # Contains fake implementations for now
  isUsernameAvailable: (desiredUsername) ->
    deferred = RSVP.defer()
    @$.ajax
      url:      @usernameQueryURL + desiredUsername
      type:     'GET'
      dataType: 'json'
      success: (data, textStatus, xhr) ->
        console.log data
      error: (xhr, textStatus, error) ->
        deferred.resolve(false)

    deferred.promise

  isEmailAddressAvailable: (desiredEmailAddress) ->
    deferred = RSVP.defer()
    console.log "SignupService.isEmailAddressAvailable returning fake true value"
    deferred.resolve(true)
    deferred.promise

root = global ? window
root.SignupService = SignupService
