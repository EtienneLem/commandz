describe 'CommandZ', ->
  describe 'commands', ->
    it 'stores commands', ->
      [0..9].forEach (i) -> CommandZ.execute({up: (-> i), down: (-> i)})

      expect(CommandZ.history.length).toBe(10)
      expect(CommandZ.index).toBe(9)

    it 'undo', ->
      [0..3].forEach -> CommandZ.undo()

      expect(CommandZ.history.length).toBe(10)
      expect(CommandZ.index).toBe(5)

    it 'redo', ->
      CommandZ.redo()

      expect(CommandZ.history.length).toBe(10)
      expect(CommandZ.index).toBe(6)

    it 'undo many times', ->
      CommandZ.undo(3)
      expect(CommandZ.history.length).toBe(10)
      expect(CommandZ.index).toBe(3)

      CommandZ.undo(100)
      expect(CommandZ.history.length).toBe(10)
      expect(CommandZ.index).toBe(-1)

    it 'redo many times', ->
      CommandZ.redo(3)
      expect(CommandZ.history.length).toBe(10)
      expect(CommandZ.index).toBe(2)

      CommandZ.redo(100)
      expect(CommandZ.history.length).toBe(10)
      expect(CommandZ.index).toBe(9)

    it 'returns current status', ->
      status = CommandZ.status()

      expect(status.canUndo).toBe(true)
      expect(status.canRedo).toBe(false)

    it 'overwrites upcoming commands', ->
      CommandZ.undo(3)
      CommandZ.execute({up: (->), down: (->)})

      expect(CommandZ.history.length).toBe(8)
      expect(CommandZ.index).toBe(7)

    it 'clears commands', ->
      CommandZ.clear()

      expect(CommandZ.history.length).toBe(0)
      expect(CommandZ.index).toBe(-1)

    it 'stores grouped commands', ->
      CommandZ.execute([{up: (->), down: (->)}, {up: (->), down: (->)}])

      expect(CommandZ.history.length).toBe(1)
      expect(CommandZ.history[0].command.length).toBe(2)

      expect(CommandZ.index).toBe(0)

    it 'registers onStatusChange callback', ->
      CommandZ.clear()
      [0..2].forEach (i) -> CommandZ.execute({up: (-> i), down: (-> i)})

      onStatusChangeCallback = jasmine.createSpy('onStatusChangeCallback')
      CommandZ.onStatusChange (status) -> onStatusChangeCallback('test')

      CommandZ.undo(3)
      CommandZ.redo(2)
      CommandZ.execute({up: (->), down: (->)})

      expect(onStatusChangeCallback.calls.length).toBe(7)
      CommandZ.onStatusChange(null)

  describe 'storage', ->
    data = null

    beforeEach ->
      CommandZ.clear()
      CommandZ.onStorageChange(null)
      CommandZ.setThreshold(0)

      [1..3].forEach (i) -> CommandZ.store({ width: i * 100, height: i * 100 })

    it 'stores data', ->
      expect(CommandZ.history.length).toBe(3)
      expect(CommandZ.index).toBe(2)

    it 'undo', ->
      CommandZ.onStorageChange (storageData) -> data = storageData
      CommandZ.undo()

      expect(data).toEqual({ width: 200, height: 200 })

    it 'redo', ->
      CommandZ.undo()
      CommandZ.onStorageChange (storageData) -> data = storageData
      CommandZ.redo()

      expect(data).toEqual({ width: 300, height: 300 })

    it 'undo and redo many times', ->
      spyOn(CommandZ, 'sendData')

      CommandZ.undo(2)
      CommandZ.redo(2)
      expect(CommandZ.sendData.calls.length).toBe(4)

      CommandZ.redo(100)
      expect(CommandZ.sendData.calls.length).toBe(4)

    it 'has a threshold', ->
      spyOn(CommandZ, 'sendData')

      CommandZ.setThreshold(500)
      CommandZ.undo(100)

      waits(450)
      runs -> expect(CommandZ.sendData.calls.length).toBe(0)

      waits(100)
      runs -> expect(CommandZ.sendData.calls.length).toBe(1)

  describe 'integration', ->
    $container = null

    beforeEach ->
      CommandZ.clear()
      CommandZ.setThreshold(0)

      loadFixtures('spec_container.html')
      $container = $('#spec-container')

      [0..4].forEach ->
        $test = $('<div class="foo"></div>')
        CommandZ.execute
          up:   -> $container.append($test)
          down: -> $test.remove()

    it 'executes commands', ->
      expect($container.children().length).toBe(5)

    it 'undo', ->
      CommandZ.undo(3)
      expect($container.children().length).toBe(2)

    it 'redo', ->
      CommandZ.undo(3)
      CommandZ.redo()

      expect($container.children().length).toBe(3)

    it 'overwrites upcoming commands', ->
      CommandZ.undo(10)
      CommandZ.redo()

      $bar = $('<div class="bar"></div>')
      CommandZ.execute
        up:   -> $container.append($bar)
        down: -> $bar.remove()

      expect($container.html()).toBe('<div class="foo"></div><div class="bar"></div>')

    it 'executes grouped commands', ->
      $container.html('')
      commands = []

      [1..3].forEach (i) ->
       $i = $("<i>#{i}</i>")
       commands.push
         up:   -> $container.append($i)
         down: -> $i.remove()

      CommandZ.execute(commands)
      expect($container.html()).toBe('<i>1</i><i>2</i><i>3</i>')

      CommandZ.undo()
      expect($container.html()).toBe('')

    it 'restores states with stored data', ->
      img = new Image
      $container.html(img)

      CommandZ.onStorageChange (data) ->
        img.width = data.width
        img.height = data.height

      img.width = 100
      img.height = 100

      [1..4].forEach (i) -> CommandZ.store({ width: i * 100, height: i * 100 })

      CommandZ.undo(2)
      expect(img.width).toBe(200)

      CommandZ.redo()
      expect(img.width).toBe(300)

      CommandZ.redo(100)
      expect(img.width).toBe(400)

      CommandZ.undo(100)
      expect(img.width).toBe(100)
