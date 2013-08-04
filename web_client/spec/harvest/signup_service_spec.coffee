require '../spec_helper.coffee'
require '../../src/lib/harvest/signup_service.coffee'

# I didn't bother writing these because I was sick of working on the signup form
describe "SignupService", ->
  service = null

  stubGet = (options) ->
    instanceOptions =
      url:          "/api/username/test_username"
      type:         "GET"
      status:       200
      contentType:  "application/json"
      logging: false

    instanceOptions.url           = options.url
    instanceOptions.status        = options.status
    instanceOptions.responseText  =
      if options.responseData
        JSON.stringify(options.responseData)
      else
        # I don't actually know if this is what jQuery returns
        null

    jQuery.mockjax(instanceOptions)

  afterEach ->
    jQuery.mockjaxClear()

  beforeEach ->
    service = new SignupService(jQuery: jQuery)

  describe ".isUsernameAvailable", ->
    context "available", ->
      beforeEach ->
        stubGet
          url: "/api/username/test_username"
          status: 200
          responseData:
            status: "available"

      it "returns a true promise", ->
        service.isUsernameAvailable("test_username").then (result) ->
          expect(result).to.be.true

    context "unavailable", ->
      beforeEach ->
        stubGet
          url: "/api/username/test_username"
          status: 200
          responseData:
            status: "unavailable"

      it "returns a false promise", ->
        service.isUsernameAvailable("test_username").then (result) ->
          expect(result).to.be.false

    context "server returns an error", ->
      beforeEach ->
        stubGet
          url: "/api/username/test_username"
          status: 404 # For example

      it "returns a false promise", ->
        service.isUsernameAvailable("test_username").then (result) ->
          expect(result).to.be.false

  # Thought: are there any email addresses that need uri encoding?
  describe ".isEmailAddressAvailable", ->
    context "available", ->
      beforeEach ->
        stubGet
          url: "/api/email_address/test@email.com"
          status: 200
          responseData:
            status: "available"

      it "returns a true promise", ->
        service.isEmailAddressAvailable("test@email.com").then (result) ->
          expect(result).to.be.true

    context "unavailable", ->
      beforeEach ->
        stubGet
          url: "/api/email_address/test@email.com"
          status: 200
          responseData:
            status: "unavailable"

      it "returns a false promise", ->
        service.isEmailAddressAvailable("test@email.com").then (result) ->
          expect(result).to.be.false

    context "server returns an error", ->
      beforeEach ->
        stubGet
          url: "/api/email_address/test@email.com"
          status: 404 # For example

      it "returns a false promise", ->
        service.isEmailAddressAvailable("test@email.com").then (result) ->
          expect(result).to.be.false