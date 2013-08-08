global.fs = require('fs')
global.path = require('path')

requireWithCall = (libName, newThis) ->
  require.call(newThis, "../vendor/lib/" + libName)

requireLib = (libName) ->
  require("../vendor/lib/" + libName)

requireLib("enumerable")

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


# Require these once globally and re-use them - I think the only alternative is to
# reload jQuery inside the document every time we run it (using jsdom.env somehow),
# which I haven't yet figured out a nice way to do yet
global.document = jsdom.jsdom('')
# Foundation requires a documentElement already exist
global.document.innerHTML = "<html><head></head><body></body></html>"
global.window = document.createWindow()
global.jQuery = requireLib("jquery")
requireLib("jquery.validate")
requireLib("jquery.validate.additional-methods")
requireLib("jquery.mockjax")

requireLib("foundation/foundation")
# foundation.js sets window.Foundation explicitly, but foundation.reveal.js
# references `Foundation` rather than `window.Foundation`, so we have to put
# a reference on Node's `global` for it to find it
global.Foundation = global.window.Foundation

requireLib("foundation/foundation.reveal")
