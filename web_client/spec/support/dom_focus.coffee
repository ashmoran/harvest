# Blatantly ripped from Zombie.js, see this JSDOM issue:
# https://github.com/tmpvar/jsdom/issues/533

# Support for element focus.


HTML = require("jsdom").dom.level3.html


FOCUS_ELEMENTS = ["INPUT", "SELECT", "TEXTAREA", "BUTTON", "ANCHOR"]


# The element in focus.
#
# If no element has the focus, return the document.body.
HTML.HTMLDocument.prototype.__defineGetter__ "activeElement", ->
  @_inFocus || @body

# Change the current element in focus (or null for blur)
setFocus = (document, element)->
  inFocus = document._inFocus
  unless element == inFocus
    if inFocus
      onblur = document.createEvent("HTMLEvents")
      onblur.initEvent("blur", false, false)
      inFocus.dispatchEvent(onblur)
    if element # null to blur
      onfocus = document.createEvent("HTMLEvents")
      onfocus.initEvent("focus", false, false)
      element.dispatchEvent(onfocus)
      document._inFocus = element
      document.window.browser.emit("focus", element)

# All HTML elements have a no-op focus/blur methods.
HTML.HTMLElement.prototype.focus = ->
HTML.HTMLElement.prototype.blur = ->

# Input controls have active focus/blur elements.  JSDOM implements these as
# no-op, so we have to over-ride each prototype individually.
for elementType in [HTML.HTMLInputElement, HTML.HTMLSelectElement, HTML.HTMLTextAreaElement, HTML.HTMLButtonElement, HTML.HTMLAnchorElement]
  elementType.prototype.focus = ->
    setFocus(@ownerDocument, this)

  elementType.prototype.blur = ->
    setFocus(@ownerDocument, null)

# Capture the autofocus element and use it to change focus
setAttribute = HTML.HTMLElement.prototype.setAttribute
HTML.HTMLElement.prototype.setAttribute = (name, value)->
  setAttribute.call(this, name, value)
  if name == "autofocus"
    document = @ownerDocument
    if ~FOCUS_ELEMENTS.indexOf(@tagName) && !document._inFocus
      @focus()
