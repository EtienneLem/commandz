class CommandZ

  constructor: ->
    @VERSION = '0.0.2'
    @changeCallback = null

    this.clear()
    this.keyboardShortcuts(true)

  clear: ->
    @commands = []
    @index = -1

  keyboardShortcuts: (enable=true) ->
    addOrRemove = if enable then 'addEventListener' else 'removeEventListener'
    document[addOrRemove]('keypress', this.handleKeyboard)

  handleKeyboard: (e) =>
    return if document.activeElement.nodeName is 'INPUT'
    return unless e.keyCode is 122 and e.metaKey is true

    e.preventDefault()
    if e.shiftKey then this.redo() else this.undo()

  execute: (command) ->
    this.up(command)

    # Overwrites following commands (if @index < @commands.length)
    if (@index < @commands.length - 1)
      difference = (@commands.length - @index) - 1
      @commands.splice(-difference)

    # Push new command
    @commands.push(command)
    @index = @commands.length - 1
    this.handleChange()

  undo: (times=1) ->
    return unless this.status().canUndo

    for i in [1..times]
      return unless @commands[@index]

      this.down(@commands[@index])
      @index--

      this.handleChange()

  redo: (times=1) ->
    return unless this.status().canRedo

    for i in [1..times]
      return unless @commands[@index + 1]

      @index++
      this.up(@commands[@index])

      this.handleChange()

  # Execute up/down on a command
  # command can be a group of commands or a single command
  exec: (action, command) ->
    return command[action]() unless command instanceof Array
    c[action]() for c in command

  up:   (command) -> this.exec('up',   command)
  down: (command) -> this.exec('down', command)

  # Register onChange callback
  onChange: (callback) ->
    @changeCallback = callback
    this.handleChange()

  handleChange: ->
    return unless @changeCallback
    @changeCallback(this.status())

  # Return current status
  status: ->
    canUndo: @index > -1
    canRedo: @index < @commands.length - 1

# Singleton
@CommandZ = new CommandZ
