CommandZ = require('commandz')

# Mocks
simple = require('simple-mock')

# Chai
chai = require('chai')
chai.use(require('chai-as-promised'))
chai.config.truncateThreshold = 0

# Mocha
afterEach ->
  simple.restore()
  CommandZ.clear()

# Helpers
helpers =
  delay: (duration, done, asserts) =>
    [asserts, done] = [done, null] if !asserts

    setTimeout =>
      asserts()
      done?()
    , duration

  callbackSequence: (callbacks) ->
    fn = ->
      returnValue = @_callbacks[@_nextIndex]()
      @_nextIndex += 1 unless @_nextIndex == @_callbacks.length - 1
      returnValue

    fn._callbacks = callbacks
    fn._nextIndex = 0
    fn.bind(fn)

# Export
module.exports =
  CommandZ: CommandZ
  simple: simple
  expect: chai.expect
  helpers: helpers
