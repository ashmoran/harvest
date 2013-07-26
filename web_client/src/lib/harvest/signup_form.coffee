RSVP.configure 'onerror', (error) ->
  throw error

jQuery.validator.addMethod(
  "available"
  (value, element) ->
    jQuery(element).data('availability') != 'taken'
  "This is already taken"
)

class CalmDelegate
  # The only reason we don't construct this with the target is that the
  # current implementation of SignupForm binds the DOM events itself, so
  # we don't have the SignupForm until after we know where want to send
  # the delayed delegated call (ie, here)
  constructor: (methodName, waitTime) ->
    @methodName = methodName
    @waitTime   = waitTime
    @timer      = null
    @call       = null

  doIt: (target) ->
    @forgetIt()
    @call = => target[@methodName]()
    @timer = setTimeout(@call, @waitTime)

  forgetIt: ->
    clearTimeout(@timer)

  hurryUp: ->
    @forgetIt()
    @call() if @call

class SignupService
  constructor: (dependencies) ->
    @$    = dependencies.jQuery

    @signUpURL        = "/api/fisherman-registrar"
    @usernameQueryURL = "/api/usernames"

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
      url:      @usernameQueryURL + "?username=" + desiredUsername
      type:     'GET'
      dataType: 'json'
      success: (data, textStatus, xhr) ->
        console.log "Didn't expect success!"
      error: (xhr, textStatus, error) ->
        console.log "SignupService.isUsernameAvailable returning fake true value"
        deferred.resolve(true)
        # console.log "SignupService.isUsernameAvailable returning fake false value"
        # deferred.resolve(false)

    deferred.promise

  isEmailAddressAvailable: (desiredEmailAddress) ->
    deferred = RSVP.defer()
    console.log "SignupService.isEmailAddressAvailable returning fake true value"
    deferred.resolve(true)
    deferred.promise

class SignupForm
  constructor: (formSelector, dependencies) ->
    @$                     = dependencies.jQuery
    @signupService         = dependencies.signupService
    @availabilityDelegates =
      username:       dependencies.usernameAvailabilityDelegate
      email_address:  dependencies.emailAddressAvailabilityDelegate

    @form = @$(formSelector)

    @previousInputValue =
      username:     null
      emailAddress: null

    @identifiersAvailable =
      username:     false
      emailAddress: false

  enhance: ->
    # The CSS hides them, but the tests don't know that
    @_hideSpinners()
    @_hideAvailabilityIndicators()
    @_bindInputChangeHandlers()

    @form.validate
      rules:
        username:
          required:     true
          alphanumeric: true
          available:    true

        email_address:
          required: true
          email:    true

        password: "required"

        confirm_password:
          required:
            param: true
            depends: (element) =>
              # TODO: use `input`
              @form.find("input[name='password']").is(":filled")
          equalTo:
            param: "input[name='password']"
            depends: (element) =>
              @form.find("input[name='password']").is(":filled")

      messages:
        username:
          required:     "Please provide a username"
          alphanumeric: "Usernames can only use letters, numbers and _"
          available:    "This username is already taken"

        email_address:
          required: "Please provide an email address"
          email:    "Please provide a valid email address"

        password: "Please provide a password"

        confirm_password:
          required: "Please retype your password"
          equalTo: "Make sure you retype it exactly"

      onfocusout: (element, event) =>
        if @$(element).attr("name") == "confirm_password"
          @$(element).valid()
        else
          @$(element).valid() unless @$(element).is(":blank")

      errorClass: "invalid"

      highlight: (element, errorClass, validClass) =>
        @$(element).parents(".field-container").addClass(errorClass).removeClass(validClass)

      unhighlight: (element, errorClass, validClass) =>
        @$(element).parents(".field-container").removeClass(errorClass).addClass(validClass)

      submitHandler: @_submit

  checkUsernameAvailability: ->
    @checkIdentifierAvailability('username')

  checkEmailAddressAvailability: ->
    @checkIdentifierAvailability('email_address')

  checkIdentifierAvailability: (name) =>
    @_spinner(name).show()

    # This is the only bit I couldn't easily factor out nicely
    serviceMethod =
      if name == 'username'
        'isUsernameAvailable'
      else
        'isEmailAddressAvailable'

    @signupService[serviceMethod](@_inputValue(name)).then (isAvailable) =>
      @_spinner(name).hide()
      if isAvailable
        @_availabilityIndicator(name).show()
        @identifiersAvailable[name] = true
      else
        @_input(name).data('availability', 'taken')
      @form.validate().element("input[name='#{name}']")

  # Because jQuery Validate doesn't understand promises, we have to add
  # our own handler to prevent form submissions based on the username check
  _submit: =>
    if @identifiersAvailable['username']
      @signupService.signUp(@_data())

  _success: (responseText, statusText, xhr, form) ->
    console.log responseText
    console.log statusText
    console.log xhr

  _data: (element) ->
    {
      username:       @_inputValue("username")
      email_address:  @_inputValue("email_address")
      password:       @_inputValue("password")
    }

  _bindInputChangeHandlers: ->
    @_bindAvailabilityCheck('username')
    @_bindAvailabilityCheck('email_address')

  _bindAvailabilityCheck: (name) ->
    @previousInputValue[name] = @_input(name).val()

    @_input(name).keyup =>
      newUsernameValue = @_input(name).val()

      if newUsernameValue != @previousInputValue[name]
        if newUsernameValue.match(/^\s*$/)
          @availabilityDelegates[name].forgetIt()
        else
          @availabilityDelegates[name].doIt(@)

        @_availabilityIndicator(name).hide()

        @previousInputValue[name] = @_input(name).val()

    @_input(name).blur =>
      @availabilityDelegates[name].hurryUp(@)

  _hideSpinners: ->
    @_spinner("username").hide()
    @_spinner("email_address").hide()

  _hideAvailabilityIndicators: ->
    @_availabilityIndicator("username").hide()
    @_availabilityIndicator("email_address").hide()

  _spinner: (name) ->
    @form.find(".#{name}-container .loading-spinner")

  _availabilityIndicator: (name) ->
    @form.find(".#{name}-container .availability-indicator")

  _inputValue: (name) ->
    @form.find("input[name='#{name}']").val()

  _input: (name) ->
    @form.find("input[name='#{name}']")

root = global ? window
root.CalmDelegate = CalmDelegate
root.SignupService = SignupService
root.SignupForm = SignupForm
