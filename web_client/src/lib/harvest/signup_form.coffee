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

  doIt: (target) ->
    @forgetIt()

    @timer = setTimeout(
      => target[@methodName]()
      @waitTime
    )

  forgetIt: ->
    clearTimeout(@timer)

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

class SignupForm
  constructor: (formSelector, dependencies) ->
    @$                            = dependencies.jQuery
    @signupService                = dependencies.signupService
    @usernameAvailibilityDelegate = dependencies.usernameAvailibilityDelegate

    @form = @$(formSelector)

    @usernameAvailable = false

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

  checkUsernameAvailability: =>
    @_spinner('username').show()
    @signupService.isUsernameAvailable(@_inputValue("username")).then (isAvailable) =>
      @_spinner('username').hide()
      if isAvailable
        @_availabilityIndicator("username").show()
        @usernameAvailable = true
        console.log "@usernameAvailable!!!"
      else
        @_input('username').data('availability', 'taken')
      @form.validate().element("input[name='username']")

  # Because jQuery Validate doesn't understand promises, we have to add
  # our own handler to prevent form submissions based on the username check
  _submit: =>
    if @usernameAvailable
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
    @_input("username").keyup =>
      @usernameAvailibilityDelegate.doIt(@)

      # MOVE ME
      # clearTimeout(@usernameTimeout)
      # @_spinner("username").hide()
      # @usernameTimeout = setTimeout(@_checkUsernameAvalibility, 2000)

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
