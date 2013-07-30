global.fs = require('fs')
global.path = require('path')

require('../vendor/lib/enumerable')

chai = require('chai')
global.expect = chai.expect
global.sinon = require('sinon')
sinonChai = require('sinon-chai')
chai.use(sinonChai)
chaiAsPromised = require('chai-as-promised')
chai.use(chaiAsPromised);
mochaAsPromised = require('mocha-as-promised')
mochaAsPromised()

global.RSVP = require('rsvp')

global.jsdom = require('jsdom')
require('./support/dom_focus.coffee')

global.fileURL = (relativePath) -> "file:///" + path.resolve(relativePath)

global.require_jQuery = ->
  require('../vendor/lib/jquery.js')

global.require_jQuery_Validate = ->
  require('../vendor/lib/jquery.validate.js')

global.require_jQuery_Validate_AdditionalMethods = ->
  require('../vendor/lib/jquery.validate.additional-methods')

# Require these once globally and re-use them - I think the only alternative is to
# reload jQuery inside the document every time we run it (using jsdom.env somehow),
# which I haven't yet figured out a nice way to do yet
global.document = jsdom.jsdom('')
global.window = document.createWindow()
global.jQuery = require_jQuery()
require_jQuery_Validate()
require_jQuery_Validate_AdditionalMethods()
