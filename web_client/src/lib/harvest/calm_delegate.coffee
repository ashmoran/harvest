# A CalmDelegate is an object that will make a delegated method call
# after a certain time, but buffers against the originating object
# changing its mind. So even if the call is requested several times,
# it will only be made once after the timeout delay. If the originating
# object knows what it's doing, it can tell the CalmDelegate to hurry up.
class CalmDelegate
  # The only reason we don't construct this with the target is that the
  # current implementation of SignupForm binds the DOM events itself, so
  # we don't have the SignupForm until after we know where want to send
  # the delayed delegated call (ie, here)
  constructor: (methodName, waitTime) ->
    @methodName = methodName
    @waitTime   = waitTime
    @timer      = null
    @call       = null

  doIt: (target) ->
    @forgetIt()
    @call = => target[@methodName]()
    @timer = setTimeout(@call, @waitTime)

  forgetIt: ->
    clearTimeout(@timer)

  hurryUp: ->
    @forgetIt()
    @call() if @call

root = global ? window
root.CalmDelegate = CalmDelegate
