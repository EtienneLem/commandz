{ CommandZ, simple, expect, helpers } = require('./spec_helper.coffee')
{ delay } = helpers

describe 'CommandZ', ->
  describe 'commands', ->
    beforeEach ->
      [0..9].forEach (i) -> CommandZ.execute({ up: (-> i), down: (-> i) })

    it 'stores commands', ->
      expect(CommandZ.history.length).to.equal(10)
      expect(CommandZ.index).to.equal(9)

    it 'undo', ->
      [0..3].forEach -> CommandZ.undo()

      expect(CommandZ.history.length).to.equal(10)
      expect(CommandZ.index).to.equal(5)

    it 'redo', ->
      [0..3].forEach -> CommandZ.undo()
      CommandZ.redo()

      expect(CommandZ.history.length).to.equal(10)
      expect(CommandZ.index).to.equal(6)

    it 'undo many times', ->
      CommandZ.undo(3)
      expect(CommandZ.history.length).to.equal(10)
      expect(CommandZ.index).to.equal(6)

      CommandZ.undo(100)
      expect(CommandZ.history.length).to.equal(10)
      expect(CommandZ.index).to.equal(-1)

    it 'redo many times', ->
      CommandZ.undo(100)
      CommandZ.redo(3)
      expect(CommandZ.history.length).to.equal(10)
      expect(CommandZ.index).to.equal(2)

      CommandZ.redo(100)
      expect(CommandZ.history.length).to.equal(10)
      expect(CommandZ.index).to.equal(9)

    it 'returns current status', ->
      status = CommandZ.status()

      expect(status.canUndo).to.equal(true)
      expect(status.canRedo).to.equal(false)

    it 'overwrites upcoming commands', ->
      CommandZ.undo(3)
      CommandZ.execute({ up: (->), down: (->) })

      expect(CommandZ.history.length).to.equal(8)
      expect(CommandZ.index).to.equal(7)

    it 'clears commands', ->
      expect(CommandZ.history.length).to.equal(10)
      CommandZ.clear()

      expect(CommandZ.history.length).to.equal(0)
      expect(CommandZ.index).to.equal(-1)

    it 'stores grouped commands', ->
      CommandZ.clear()
      CommandZ.execute [
        { up: (->), down: (->) }
        { up: (->), down: (->) }
      ]

      expect(CommandZ.history.length).to.equal(1)
      expect(CommandZ.history[0].command.length).to.equal(2)

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
    data = null

    beforeEach ->
      CommandZ.reset()
      [1..3].forEach (i) -> CommandZ.store({ width: i * 100, height: i * 100 })

    it 'stores data', ->
      expect(CommandZ.history.length).to.equal(3)
      expect(CommandZ.index).to.equal(2)

    it 'undo', ->
      CommandZ.onStorageChange (storageData) -> data = storageData
      CommandZ.undo()

      expect(data).to.deep.equal({ width: 200, height: 200 })

    it 'redo', ->
      CommandZ.undo()
      CommandZ.onStorageChange (storageData) -> data = storageData
      CommandZ.redo()

      expect(data).to.deep.equal({ width: 300, height: 300 })

    it 'undo and redo many times', ->
      simple.mock(CommandZ, 'sendData')

      CommandZ.undo(2)
      CommandZ.redo(2)
      expect(CommandZ.sendData.calls.length).to.equal(4)

      CommandZ.redo(100)
      expect(CommandZ.sendData.calls.length).to.equal(4)

    it 'has a threshold', (done) ->
      simple.mock(CommandZ, 'sendData')

      CommandZ.setThreshold(50)
      CommandZ.undo(100)

      delay 45, ->
        expect(CommandZ.sendData.calls.length).to.equal(0)

        delay 10, done, ->
          expect(CommandZ.sendData.calls.length).to.equal(1)
