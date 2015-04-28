{ CommandZ, simple, expect, helpers } = require('./spec_helper.coffee')
{ delay } = helpers

describe 'CommandZ', ->
  describe 'actions', ->
    beforeEach ->
      @spies = []
      [0..9].forEach (i) =>
        @spies[i] = spy = { up: simple.spy(-> i), down: simple.spy(-> i) }
        CommandZ.execute(spy)

      this.getSpiesCalls = ->
        calls = []
        for spy in @spies
          calls.push
            up: spy.up.calls.length
            down: spy.down.calls.length

        calls

    it 'stores actions', ->
      expect(CommandZ.history.length).to.equal(10)
      expect(CommandZ.index).to.equal(9)

    it 'undo', ->
      [0..3].forEach -> CommandZ.undo()

      expect(CommandZ.history.length).to.equal(10)
      expect(CommandZ.index).to.equal(5)

      expect(this.getSpiesCalls()).to.deep.equal [
        { up: 1, down: 0 }
        { up: 1, down: 0 }
        { up: 1, down: 0 }
        { up: 1, down: 0 }
        { up: 1, down: 0 }
        { up: 1, down: 0 }
        { up: 1, down: 1 }
        { up: 1, down: 1 }
        { up: 1, down: 1 }
        { up: 1, down: 1 }
      ]

    it 'redo', ->
      [0..3].forEach -> CommandZ.undo()
      CommandZ.redo()

      expect(CommandZ.history.length).to.equal(10)
      expect(CommandZ.index).to.equal(6)

      expect(this.getSpiesCalls()).to.deep.equal [
        { up: 1, down: 0 }
        { up: 1, down: 0 }
        { up: 1, down: 0 }
        { up: 1, down: 0 }
        { up: 1, down: 0 }
        { up: 1, down: 0 }
        { up: 2, down: 1 }
        { up: 1, down: 1 }
        { up: 1, down: 1 }
        { up: 1, down: 1 }
      ]

    it 'undo many times', ->
      CommandZ.undo(3)
      expect(CommandZ.history.length).to.equal(10)
      expect(CommandZ.index).to.equal(6)

      expect(this.getSpiesCalls()).to.deep.equal [
        { up: 1, down: 0 }
        { up: 1, down: 0 }
        { up: 1, down: 0 }
        { up: 1, down: 0 }
        { up: 1, down: 0 }
        { up: 1, down: 0 }
        { up: 1, down: 0 }
        { up: 1, down: 1 }
        { up: 1, down: 1 }
        { up: 1, down: 1 }
      ]

      CommandZ.undo(100)
      expect(CommandZ.history.length).to.equal(10)
      expect(CommandZ.index).to.equal(-1)

      expect(this.getSpiesCalls()).to.deep.equal [
        { up: 1, down: 1 }
        { up: 1, down: 1 }
        { up: 1, down: 1 }
        { up: 1, down: 1 }
        { up: 1, down: 1 }
        { up: 1, down: 1 }
        { up: 1, down: 1 }
        { up: 1, down: 1 }
        { up: 1, down: 1 }
        { up: 1, down: 1 }
      ]

    it 'redo many times', ->
      CommandZ.undo(100)
      CommandZ.redo(3)
      expect(CommandZ.history.length).to.equal(10)
      expect(CommandZ.index).to.equal(2)

      expect(this.getSpiesCalls()).to.deep.equal [
        { up: 2, down: 1 }
        { up: 2, down: 1 }
        { up: 2, down: 1 }
        { up: 1, down: 1 }
        { up: 1, down: 1 }
        { up: 1, down: 1 }
        { up: 1, down: 1 }
        { up: 1, down: 1 }
        { up: 1, down: 1 }
        { up: 1, down: 1 }
      ]

      CommandZ.redo(100)
      expect(CommandZ.history.length).to.equal(10)
      expect(CommandZ.index).to.equal(9)

      expect(this.getSpiesCalls()).to.deep.equal [
        { up: 2, down: 1 }
        { up: 2, down: 1 }
        { up: 2, down: 1 }
        { up: 2, down: 1 }
        { up: 2, down: 1 }
        { up: 2, down: 1 }
        { up: 2, down: 1 }
        { up: 2, down: 1 }
        { up: 2, down: 1 }
        { up: 2, down: 1 }
      ]

    it 'returns current status', ->
      status = CommandZ.status()

      expect(status.canUndo).to.equal(true)
      expect(status.canRedo).to.equal(false)

    it 'overwrites upcoming actions', ->
      CommandZ.undo(3)
      CommandZ.execute({ up: (->), down: (->) })

      expect(CommandZ.history.length).to.equal(8)
      expect(CommandZ.index).to.equal(7)

    it 'clears history', ->
      expect(CommandZ.history.length).to.equal(10)
      CommandZ.clear()

      expect(CommandZ.history.length).to.equal(0)
      expect(CommandZ.index).to.equal(-1)

    it 'stores grouped actions', ->
      CommandZ.clear()
      CommandZ.execute [
        { up: (->), down: (->) }
        { up: (->), down: (->) }
      ]

      expect(CommandZ.history.length).to.equal(1)
      expect(CommandZ.history[0].grouped).to.be.true

      expect(CommandZ.index).to.equal(0)

    it 'registers onStatusChange callback', ->
      onStatusChangeCallback = simple.spy(->)
      CommandZ.onStatusChange (status) -> onStatusChangeCallback('test')

      CommandZ.undo(3)
      CommandZ.redo(2)
      CommandZ.execute({ up: (->), down: (->) })

      expect(onStatusChangeCallback.calls.length).to.equal(7)
      CommandZ.onStatusChange(null)

  describe 'storage', ->
    beforeEach ->
      CommandZ.reset()
      [1..3].forEach (i) -> CommandZ.store({ width: i * 100, height: i * 100 })

    it 'stores data', ->
      expect(CommandZ.history.length).to.equal(3)
      expect(CommandZ.index).to.equal(2)

    it 'undo', ->
      spy = simple.spy(->)
      CommandZ.onStorageChange(spy)
      CommandZ.undo()

      expect(spy.firstCall.args[0]).to.deep.equal({ width: 200, height: 200 })

    it 'redo', ->
      CommandZ.undo()
      spy = simple.spy(->)
      CommandZ.onStorageChange(spy)
      CommandZ.redo()

      expect(spy.firstCall.args[0]).to.deep.equal({ width: 300, height: 300 })

    it 'undo and redo many times', ->
      simple.mock(CommandZ, 'sendData')

      CommandZ.undo(2)
      CommandZ.redo(2)
      expect(CommandZ.sendData.calls.length).to.equal(4)

      CommandZ.redo(100)
      expect(CommandZ.sendData.calls.length).to.equal(4)

    it 'has a threshold', (done) ->
      simple.mock(CommandZ, 'sendData')

      CommandZ.setThreshold(10)
      CommandZ.undo(100)

      delay 5, ->
        expect(CommandZ.sendData.calls.length).to.equal(0)

        delay 6, done, ->
          expect(CommandZ.sendData.calls.length).to.equal(1)
