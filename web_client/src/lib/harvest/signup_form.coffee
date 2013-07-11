class SignupForm
  constructor: (formSelector, dependencies) ->
    @$ = dependencies.jQuery
    @form = @$(formSelector)

  enhance: ->
    @form.validate
      rules:
        username:
          required:     true
          alphanumeric: true

        email_address:
          required: true
          email:    true

        password: "required"

        confirm_password:
          required:
            param: true
            depends: (element) =>
              @form.find("input[name='password']").is(":filled")
          equalTo:
            param: "input[name='password']"
            depends: (element) =>
              @form.find("input[name='password']").is(":filled")

      messages:
        username:
          required:     "Please provide a username"
          alphanumeric: "Usernames can only use letters, numbers and _"

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

      submitHandler: -> false

  _success: (responseText, statusText, xhr, form) ->
    console.log responseText
    console.log statusText
    console.log xhr

root = global ? window
root.SignupForm = SignupForm
