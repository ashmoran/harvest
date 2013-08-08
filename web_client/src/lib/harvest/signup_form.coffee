# TODO: find a home for these initialization concerns

RSVP.configure 'onerror', (error) ->
  throw error

jQuery.validator.addMethod(
  "available"
  (value, element) ->
    jQuery(element).data('availability') != 'taken'
  "This is already taken"
)

class SignupForm
  @build = (options) ->
    signupService = new SignupService(jQuery: jQuery)

    usernameAvailabilityDelegate =
      new CalmDelegate('checkUsernameAvailability', options.checkDelay)
    emailAddressAvailabilityDelegate =
      new CalmDelegate('checkEmailAddressAvailability', options.checkDelay)

    new @ options.formSelector,
      jQuery:                           jQuery,
      signupService:                    signupService,
      usernameAvailabilityDelegate:     usernameAvailabilityDelegate,
      emailAddressAvailabilityDelegate: emailAddressAvailabilityDelegate

  constructor: (formSelector, dependencies) ->
    @$                     = dependencies.jQuery
    @signupService         = dependencies.signupService
    @availabilityDelegates =
      username:       dependencies.usernameAvailabilityDelegate
      email_address:  dependencies.emailAddressAvailabilityDelegate

    @form = @$(formSelector)

    @previousInputValue =
      username:       null
      email_address:  null

    @identifiersAvailable =
      username:       false
      email_address:  false

  enhance: ->
    # The CSS hides them, but the tests don't know that
    @_hideSpinners()
    @_hideAvailabilityIndicators()
    @_bindInputChangeHandlers()

    @validator = @form.validate
      rules:
        username:
          required:     true
          alphanumeric: true
          available:    true
          maxlength:    16

        email_address:
          required: true
          email:    true

        password:
          required: true

        confirm_password:
          required:
            param: true
            depends: (element) =>
              @_input('password').is(":filled") || @_input('password').is(":blank")
          equalTo:
            param: @_input('password')
            depends: (element) =>
              @_input('password').is(":filled")

      messages:
        username:
          required:     "Please provide a username"
          alphanumeric: "Usernames can only use letters, numbers and _"
          available:    "This username is already taken"
          maxlength:    "Usernames must be 16 characters or less"

        email_address:
          required: "Please provide an email address"
          email:    "Please provide a valid email address"

        password: "Please choose a password"

        confirm_password:
          required: "Please retype your password"
          equalTo: "Make sure you retype it exactly"

      onfocusout: (element, event) =>
        switch @$(element).attr("name")
          when 'password'
            @$(element).valid() unless @_input('password').is(":blank")
          when 'confirm_password'
            if @_input('password').is(":filled")
              @$(element).valid()
            else
              @$(element).valid() unless @$(element).is(":blank")
          else
            @$(element).valid() unless @$(element).is(":blank")

      errorClass: "error"
      errorElement: "small"

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
    return unless @validator.element(@_input(name))

    @_spinner(name).show()

    # This is the only bit I couldn't easily factor out nicely
    serviceMethod =
      switch name
        when 'username'       then 'isUsernameAvailable'
        when 'email_address'  then 'isEmailAddressAvailable'

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
  _submit: (form) =>
    if @identifiersAvailable['username'] && @identifiersAvailable['email_address']
      @signupService.signUp(@_data()).then(@_handleSignupResponse)

  _handleSignupResponse: (response) =>
    messageModal =
      switch response
        when true  then '#signup-confirmation'
        when false then '#signup-error-message'

    @$(messageModal).foundation('reveal', 'open')

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
      newValue = @_input(name).val()

      if newValue != @previousInputValue[name]
        @_input(name).removeData('availability')
        @identifiersAvailable[name] = false

        if newValue.match(/^\s*$/)
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
root.SignupForm = SignupForm
