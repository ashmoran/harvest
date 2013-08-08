require '../spec_helper.coffee'
require '../../src/lib/harvest/signup_service.coffee'

# I didn't bother writing these because I was sick of working on the signup form
describe "SignupService", ->
  service = null

  stubGet = (options) ->
    stubRequest('GET', options)

  stubPost = (options) ->
    stubRequest('POST', options)

  stubRequest = (method, options) ->
    instanceOptions =
      url:          options.path
      type:         method
      status:       200
      contentType:  "application/json"
      logging: false

    instanceOptions.url           = options.path
    instanceOptions.status        = options.status
    instanceOptions.responseText  =
      if options.responseData
        JSON.stringify(options.responseData)
      else
        # I don't actually know if this is what jQuery returns
        null
    if options.requestData
      instanceOptions.data = options.requestData

    jQuery.mockjax(instanceOptions)

  afterEach ->
    jQuery.mockjaxClear()

  beforeEach ->
    service = new SignupService(jQuery: jQuery)

  describe ".signUp", ->
    context "valid", ->
      beforeEach ->
        stubPost
          path: "/api/fisherman-registrar"
          status: 200
          requestData: JSON.stringify(foo: "bar")

      it "returns a true promise", ->
        service.signUp(foo: "bar").then (result) ->
          expect(result).to.be.true

    context "conflicts", ->
      beforeEach ->
        stubPost
          path: "/api/fisherman-registrar"
          status: 409
          requestData: JSON.stringify(foo: "bar")

      it "returns a false promise", ->
        # Unfortunately we also get an error response from mockjax if
        # we don't provide the correct request data ({foo: "bar"}), but
        # I haven't yet looked for a way to distinguish that
        service.signUp(foo: "bar").then (result) ->
          expect(result).to.be.false

  describe ".isUsernameAvailable", ->
    context "available", ->
      beforeEach ->
        stubGet
          path: "/api/username/test_username"
          status: 200
          responseData:
            status: "available"

      it "returns a true promise", ->
        service.isUsernameAvailable("test_username").then (result) ->
          expect(result).to.be.true

    context "unavailable", ->
      beforeEach ->
        stubGet
          path: "/api/username/test_username"
          status: 200
          responseData:
            status: "unavailable"

      it "returns a false promise", ->
        service.isUsernameAvailable("test_username").then (result) ->
          expect(result).to.be.false

    context "server returns an error", ->
      beforeEach ->
        stubGet
          path: "/api/username/test_username"
          status: 404 # For example

      it "returns a false promise", ->
        service.isUsernameAvailable("test_username").then (result) ->
          expect(result).to.be.false

  # Thought: are there any email addresses that need uri encoding?
  describe ".isEmailAddressAvailable", ->
    context "available", ->
      beforeEach ->
        stubGet
          path: "/api/email_address/test@email.com"
          status: 200
          responseData:
            status: "available"

      it "returns a true promise", ->
        service.isEmailAddressAvailable("test@email.com").then (result) ->
          expect(result).to.be.true

    context "unavailable", ->
      beforeEach ->
        stubGet
          path: "/api/email_address/test@email.com"
          status: 200
          responseData:
            status: "unavailable"

      it "returns a false promise", ->
        service.isEmailAddressAvailable("test@email.com").then (result) ->
          expect(result).to.be.false

    context "server returns an error", ->
      beforeEach ->
        stubGet
          path: "/api/email_address/test@email.com"
          status: 404 # For example

      it "returns a false promise", ->
        service.isEmailAddressAvailable("test@email.com").then (result) ->
          expect(result).to.be.false