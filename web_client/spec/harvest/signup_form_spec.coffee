require '../spec_helper.coffee'
require '../../src/lib/harvest/signup_form.coffee'

describe "CalmDelegate", ->
  clock = null
  beforeEach -> clock = sinon.useFakeTimers()
  afterEach  -> clock.restore()

  target    = null
  delegate  = null

  beforeEach ->
    target =
      methodIWantCalled: sinon.spy()

    delegate = new CalmDelegate('methodIWantCalled', 1000)

  describe "doIt", ->
    beforeEach ->
      delegate.doIt(target)

    context "not waiting", ->
      it "doesn't call the target method", ->
        expect(target.methodIWantCalled).to.not.have.been.called

    context "waiting less than the delay time", ->
      it "doesn't call the target method", ->
        clock.tick(999)
        expect(target.methodIWantCalled).to.not.have.been.called

    context "waiting the delay time", ->
      it "calls the target method", ->
        clock.tick(1000)
        expect(target.methodIWantCalled).to.have.been.calledOnce

    context "calling again part way through the wait time", ->
      beforeEach ->
        clock.tick(500)
        delegate.doIt(target)

      context "then waiting until the original wait time has elapsed", ->
        beforeEach ->
          clock.tick(500)

        it "no longer calls the method", ->
          expect(target.methodIWantCalled).to.not.have.been.called

      context "then waiting until the wait time has elapsed again", ->
        beforeEach ->
          clock.tick(1000)

        it "calls the method", ->
          expect(target.methodIWantCalled).to.have.been.calledOnce

  describe "forgetIt", ->
    it "cancels the call", ->
      delegate.doIt(target)
      delegate.forgetIt()
      clock.tick(1000)
      expect(target.methodIWantCalled).to.not.have.been.called

  describe "hurryUp", ->
    context "no call pending", ->
      it "does nothing", ->
        delegate.hurryUp()
        expect(target.methodIWantCalled).to.not.have.been.called

    context "a call pending", ->
      beforeEach ->
        delegate.doIt(target)

      it "makes the call immediately", ->
        delegate.hurryUp()
        expect(target.methodIWantCalled).to.have.been.calledOnce

      it "doesn't make the call again after the delay", ->
        delegate.hurryUp()
        clock.tick(1000)
        expect(target.methodIWantCalled).to.have.been.calledOnce

describe "SignupForm", ->
  signupHtml = fs.readFileSync('web_client/www/pages/signup.html', encoding: 'utf-8')

  # Dependencies
  signupService = null
  usernameAvailabilityDelegate = null
  emailAddressAvailabilityDelegate = null

  form    = null
  domForm = null

  # I made .{username,email_address}-container classes to help with the spinners,
  # maybe we should use that for the fieldContainer lookup?
  fieldContainer          = (name) -> input(name).parents(".field-container")
  input                   = (name) -> domForm.find("input[name='#{name}']")
  errorLabel              = (name) -> domForm.find("label.invalid[for='#{name}']")
  spinner                 = (name) -> fieldContainer(name).find(".loading-spinner")
  availabilityIndicator   = (name) -> fieldContainer(name).find(".availability-indicator")

  fillValidDetails = ->
    input("username").val("Valid_123")
    input("email_address").val("valid@email.com")
    input("password").val("valid password")
    input("confirm_password").val("valid password")

  typeUsername = (value) ->
    input("username").val(value)
    input("username").keyup()

  beforeEach ->
    # Odd way of resetting the page, but it's the best I can find
    document.innerHTML = signupHtml

    domForm = jQuery("form#signup")

    signupService =
      signUp:                   sinon.spy()
      isUsernameAvailable:      sinon.spy()
      isEmailAddressAvailable:  sinon.spy()

    usernameAvailabilityDelegate =
      doIt:     sinon.spy()
      hurryUp:  sinon.spy()
      forgetIt: sinon.spy()

    # We don't actually test anything to do with this
    emailAddressAvailabilityDelegate =
      doIt:     sinon.stub()
      hurryUp:  sinon.stub()
      forgetIt: sinon.stub()

    form = new SignupForm "form#signup",
      signupService:                    signupService
      jQuery:                           jQuery
      usernameAvailabilityDelegate:     usernameAvailabilityDelegate
      emailAddressAvailabilityDelegate: emailAddressAvailabilityDelegate

    form.enhance()

  specify "page", ->
    specify "username field", ->
      expect(input("username").length).to.be.equal 1
    specify "email_address field", ->
      expect(input("email_address").length).to.be.equal 1
    specify "password field", ->
      expect(input("password").length).to.be.equal 1
    specify "confirm_password field", ->
      expect(input("confirm_password").length).to.be.equal 1

  describe "checkUsernameAvailability", ->
    usernameCheck = null
    usernameCheckReturns = null

    beforeEach ->
      usernameCheck = RSVP.defer()
      usernameCheckReturns = usernameCheck.promise
      signupService.isUsernameAvailable = sinon.stub().returns(usernameCheckReturns)

      # We don't care about this, we don't test it directly
      emailAddressCheck = RSVP.defer()
      emailAddressCheckReturns = emailAddressCheck.promise
      signupService.isEmailAddressAvailable = sinon.stub().returns(emailAddressCheckReturns)
      emailAddressCheck.resolve(true)

    context "irrespective of username availability", ->
      beforeEach ->
        typeUsername("check_me")
        form.checkUsernameAvailability()
        null

      it "shows a visual indicator", ->
        expect(spinner("username").is(":visible")).to.be.true

      it "checks for availability", ->
        expect(signupService.isUsernameAvailable).to.have.been.calledWithExactly("check_me")

    context "when the username is available", ->
      beforeEach ->
        typeUsername("unimportant")
        form.checkUsernameAvailability()
        usernameCheck.resolve(true)

      it "removes the loading indicator", ->
        usernameCheckReturns.then ->
          expect(spinner("username").is(":visible")).to.be.false

      it "displays that the username is available", ->
        usernameCheckReturns.then ->
          expect(availabilityIndicator("username").is(":visible")).to.be.true

      context "after typing but not changing the username text", ->
        beforeEach ->
          usernameCheckReturns.then ->
            typeUsername("unimportant")

        it "invalidates the previous username", ->
          expect(availabilityIndicator("username").is(":visible")).to.be.true

        it "doesn't schedule a recheck", ->
          expect(usernameAvailabilityDelegate.doIt).to.have.been.calledOnce

      context "after changing the username text", ->
        beforeEach ->
          usernameCheckReturns.then ->
            typeUsername("different")

        it "invalidates the previous username", ->
          expect(availabilityIndicator("username").is(":visible")).to.be.false

        it "permits re-checks", ->
          expect(usernameAvailabilityDelegate.doIt).to.have.been.calledTwice

        it "only rechecks changed values", ->
          typeUsername("different")
          expect(usernameAvailabilityDelegate.doIt).to.have.been.calledTwice

      context "after clearing the username text", ->
        beforeEach ->
          usernameCheckReturns.then ->
            typeUsername("")

        it "invalidates the previous username", ->
          expect(availabilityIndicator("username").is(":visible")).to.be.false

        it "does not recheck", ->
          expect(usernameAvailabilityDelegate.doIt).to.have.been.calledOnce
          expect(usernameAvailabilityDelegate.forgetIt).to.have.been.calledOnce

    context "when the username is unavailable", ->
      beforeEach ->
        typeUsername("unimportant")
        form.checkUsernameAvailability()
        usernameCheck.resolve(false)

      it "removes the loading indicator", ->
        usernameCheckReturns.then ->
          expect(spinner("username").is(":visible")).to.be.false
          form.checkUsernameAvailability()

      # TODO: explicit unavailable symbol?
      it "displays that the username is unavailable", ->
        usernameCheckReturns.then ->
          expect(availabilityIndicator("username").is(":visible")).to.be.false

      it "is marked invalid", ->
        usernameCheckReturns.then ->
          expect(fieldContainer("username").hasClass("invalid")).to.be.true

      specify "error label", ->
        usernameCheckReturns.then ->
          expect(errorLabel("username").text()).to.be.equal "This username is already taken"

      it "prevents you submitting the form", ->
        # A bit fragile, depends on form validation, and will break
        # when we add email checking
        beforeEach ->
          input("email_address").val("valid@email.com")
          input("password").val("valid password")
          input("confirm_password").val("valid password")

        usernameCheckReturns.then ->
          domForm.submit()
          expect(signupService.signUp).to.not.have.been.called

  context "just after enhancing", ->
    it "has no errors", ->
      expect(fieldContainer("username").hasClass("invalid")).to.be.false
      expect(fieldContainer("email_address").hasClass("invalid")).to.be.false
      expect(fieldContainer("password").hasClass("invalid")).to.be.false
      expect(fieldContainer("confirm_password").hasClass("invalid")).to.be.false

    it "has hidden the username spinner", ->
      expect(spinner("username").is(":hidden")).to.be.true

    it "has hidden the email spinner", ->
      expect(spinner("email_address").is(":hidden")).to.be.true

    it "has hidden that the username is available", ->
      expect(availabilityIndicator("username").is(":hidden")).to.be.true

    it "has hidden that the email address is available", ->
      expect(availabilityIndicator("email_address").is(":hidden")).to.be.true

  context "after submitting an empty form", ->
    beforeEach ->
      domForm.submit()

    describe "username", ->
      it "is marked invalid", ->
        expect(fieldContainer("username").hasClass("invalid")).to.be.true
      specify "error label", ->
        expect(errorLabel("username").text()).to.be.equal "Please provide a username"

    describe "email_address", ->
      it "is marked invalid", ->
        expect(fieldContainer("email_address").hasClass("invalid")).to.be.true
      specify "error label", ->
        expect(errorLabel("email_address").text()).to.be.equal "Please provide an email address"

    describe "password", ->
      it "is marked invalid", ->
        expect(fieldContainer("password").hasClass("invalid")).to.be.true
      specify "error label", ->
        expect(errorLabel("password").text()).to.be.equal "Please provide a password"

    describe "confirm_password", ->
      it "is not marked invalid (it's irrelevant)", ->
        expect(fieldContainer("confirm_password").hasClass("invalid")).to.be.false
      # Assume "not invalid" => "no error label is present"

    it 'has not submitted the form', ->
      expect(signupService.signUp).to.not.have.been.called

  context "invalid fields", ->
    context "invalid username", ->
      ["a b", "a!"].each (invalidUsername) ->
        context "candidate: '#{invalidUsername}'", ->
          beforeEach ->
            input("username").val(invalidUsername)
            domForm.submit()
          it "is marked invalid", ->
            expect(fieldContainer("username").hasClass("invalid")).to.be.true
          specify "error label", ->
            expect(errorLabel("username").text()).to.be.equal "Usernames can only use letters, numbers and _"

    context "invalid email address", ->
      beforeEach ->
        input("email_address").val("notanemailwecanuse")
        domForm.submit()
      it "is marked invalid", ->
        expect(fieldContainer("email_address").hasClass("invalid")).to.be.true
      specify "error label", ->
        expect(errorLabel("email_address").text()).to.be.equal "Please provide a valid email address"

    context "unconfirmed password", ->
      beforeEach ->
        input("password").val("This is a good password")
        input("confirm_password").val("")
        domForm.submit()
      it "is marked invalid", ->
        expect(fieldContainer("confirm_password").hasClass("invalid")).to.be.true
      specify "error label", ->
        expect(errorLabel("confirm_password").text()).to.be.equal "Please retype your password"

    context "incorrectly confirmed password", ->
      beforeEach ->
        input("password").val("This is a good password")
        input("confirm_password").val("This is a different password")
        domForm.submit()
      it "is marked invalid", ->
        expect(fieldContainer("confirm_password").hasClass("invalid")).to.be.true
      specify "error label", ->
        expect(errorLabel("confirm_password").text()).to.be.equal "Make sure you retype it exactly"

  context "valid details", ->
    beforeEach ->
      usernameCheckReturns = new RSVP.Promise (resolve, reject) -> resolve(true)
      signupService.isUsernameAvailable = sinon.stub().returns(usernameCheckReturns)

      # We don't care about this, we don't test it
      emailAddressCheckReturns = new RSVP.Promise (resolve, reject) -> resolve(true)
      signupService.isEmailAddressAvailable = sinon.stub().returns(emailAddressCheckReturns)

      input("username").val("Valid_123")
      form.checkUsernameAvailability()
      input("email_address").val("valid@email.com")
      input("password").val("valid password")
      input("confirm_password").val("valid password")

      usernameCheckReturns.then ->
        domForm.submit()

    it "submits the form", ->
      expect(signupService.signUp).to.have.been.calledWithExactly
        username:       "Valid_123"
        email_address:  "valid@email.com"
        password:       "valid password"

  describe "validation on focus change", ->
    it "doesn't validate empty username, etc", ->
      input("username").focus()
      input("email_address").focus()
      expect(fieldContainer("username").hasClass("invalid")).to.be.false

    it "validates a filled-in username, etc", ->
      input("username").focus()
      input("username").val("invalid username!")
      input("email_address").focus()
      expect(fieldContainer("username").hasClass("invalid")).to.be.true

    it "validates a blank password confirmation", ->
      input("password").val("this is a password")
      input("confirm_password").focus()
      input("confirm_password").blur()
      expect(fieldContainer("confirm_password").hasClass("invalid")).to.be.true

    it "checks username availability", ->
      input("username").focus()
      typeUsername("check_now")
      input("email_address").focus()
      expect(usernameAvailabilityDelegate.hurryUp).to.have.been.calledOnce

  describe "username availability checking", ->
    context "empty", ->
      it "does not check for availability", ->
        typeUsername("")
        expect(usernameAvailabilityDelegate.doIt).to.not.have.been.called

    context "blank", ->
      it "does not check for availability", ->
        typeUsername("  ")
        expect(usernameAvailabilityDelegate.doIt).to.not.have.been.called

    context "after typing an invalid username", ->
      beforeEach ->
        typeUsername("this is invalid!")

      it "does not check for availability"

    context "after typing a valid username", ->
      beforeEach ->
        fillValidDetails()
        typeUsername("new_username")

      it "wants the username checking for availability", ->
        expect(usernameAvailabilityDelegate.doIt).to.have.been.calledWithExactly(form)

      it "prevents you submitting the form", ->
        domForm.submit()
        expect(signupService.signUp).to.not.have.been.called

      it "only checks if you made a meaningful change (eg not pressing left/right)", ->
        typeUsername("new_username")
        expect(usernameAvailabilityDelegate.doIt).to.have.been.calledOnce

