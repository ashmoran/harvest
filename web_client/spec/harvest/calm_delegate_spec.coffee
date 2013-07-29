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
