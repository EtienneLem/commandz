describe 'CommandZ', ->
  describe 'unit', ->
    it 'stores commands', ->
      [0..9].forEach (i) -> CommandZ.execute({up: (-> i), down: (-> i)})

      expect(CommandZ.commands.length).toBe(10)
      expect(CommandZ.index).toBe(9)

    it 'undo', ->
      [0..3].forEach -> CommandZ.undo()

      expect(CommandZ.commands.length).toBe(10)
      expect(CommandZ.index).toBe(5)

    it 'redo', ->
      CommandZ.redo()

      expect(CommandZ.commands.length).toBe(10)
      expect(CommandZ.index).toBe(6)

    it 'undo many times', ->
      CommandZ.undo(3)
      expect(CommandZ.commands.length).toBe(10)
      expect(CommandZ.index).toBe(3)

      CommandZ.undo(100)
      expect(CommandZ.commands.length).toBe(10)
      expect(CommandZ.index).toBe(-1)

    it 'redo many times', ->
      CommandZ.redo(3)
      expect(CommandZ.commands.length).toBe(10)
      expect(CommandZ.index).toBe(2)

      CommandZ.redo(100)
      expect(CommandZ.commands.length).toBe(10)
      expect(CommandZ.index).toBe(9)

    it 'returns current status', ->
      status = CommandZ.status()

      expect(status.canUndo).toBe(true)
      expect(status.canRedo).toBe(false)

    it 'overwrites upcoming commands', ->
      CommandZ.undo(3)
      CommandZ.execute({up: (->), down: (->)})

      expect(CommandZ.commands.length).toBe(8)
      expect(CommandZ.index).toBe(7)

    it 'clears commands', ->
      CommandZ.clear()

      expect(CommandZ.commands.length).toBe(0)
      expect(CommandZ.index).toBe(-1)

    it 'stores grouped commands', ->
      CommandZ.execute([{up: (->), down: (->)}, {up: (->), down: (->)}])
      CommandZ.undo()
      CommandZ.redo()

      expect(CommandZ.commands.length).toBe(1)
      expect(CommandZ.commands[0].length).toBe(2)

      expect(CommandZ.index).toBe(0)

    it 'registers onChange callback', ->
      CommandZ.clear()
      [0..2].forEach (i) -> CommandZ.execute({up: (-> i), down: (-> i)})

      onChangeCallback = jasmine.createSpy('onChangeCallback')
      CommandZ.onChange (status) -> onChangeCallback('test')

      CommandZ.undo(3)
      CommandZ.redo(2)
      CommandZ.execute({up: (->), down: (->)})

      expect(onChangeCallback.calls.length).toBe(7)
      CommandZ.onChange(null)

  describe 'integration', ->
    $container = null

    beforeEach ->
      CommandZ.clear()
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
