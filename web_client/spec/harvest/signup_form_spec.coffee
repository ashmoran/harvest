require '../spec_helper.coffee'
require '../../src/lib/harvest/signup_form.coffee'

describe "SignupForm", ->
  signupHtml = fs.readFileSync('web_client/site/pages/signup.html', encoding: 'utf-8')

  form      = null
  domForm   = null

  input = (name) -> domForm.find("input[name='#{name}']")
  fieldContainer = (name) -> input(name).parents(".field-container")
  errorLabel = (name) -> domForm.find("label.invalid[for='#{name}']")

  beforeEach -> sinon.stub(jQuery, 'ajax')
  afterEach -> jQuery.ajax.restore()

  beforeEach ->
    # Odd way of resetting the page, but it's the best I can find
    document.innerHTML = signupHtml

    domForm = jQuery("form#signup")

    form = new SignupForm("form#signup", jQuery: jQuery)
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

  context "just after enhancing", ->
    it "has no errors", ->
      expect(fieldContainer("username").hasClass("invalid")).to.be.false
      expect(fieldContainer("email_address").hasClass("invalid")).to.be.false
      expect(fieldContainer("password").hasClass("invalid")).to.be.false
      expect(fieldContainer("confirm_password").hasClass("invalid")).to.be.false

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
      expect(jQuery.ajax).to.not.have.been.called

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

    context "icnroerctly confirmed password", ->
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
      input("username").val("ValidUsername_123")
      input("email_address").val("valid@email.com")
      input("password").val("valid password")
      input("confirm_password").val("valid password")
      domForm.submit()

    it 'submits the form', ->
      expect(jQuery.ajax).to.have.been.calledWithExactly
        url: "/api/fisherman-registrar"
        type: 'POST'
        dataType: 'json'
        data:
          JSON.stringify
            username:       "ValidUsername_123"
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
      # input("password").focus()
      input("password").val("this is a password")
      input("confirm_password").focus()
      input("confirm_password").blur()
      expect(fieldContainer("confirm_password").hasClass("invalid")).to.be.true

