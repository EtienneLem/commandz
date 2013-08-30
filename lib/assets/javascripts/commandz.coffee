class CommandZ

  constructor: ->
    @VERSION = '0.0.3'
    @statusChangeCallback = null

    this.clear()
    this.keyboardShortcuts(true)

  clear: ->
    @history = []
    @index = -1

  keyboardShortcuts: (enable=true) ->
    addOrRemove = if enable then 'addEventListener' else 'removeEventListener'
    document[addOrRemove]('keypress', this.handleKeypress)

  handleKeypress: (e) =>
    return if document.activeElement.nodeName is 'INPUT'
    return unless e.keyCode is 122 and e.metaKey is true

    e.preventDefault()
    if e.shiftKey then this.redo() else this.undo()

  execute: (command) ->
    this.up(command)

    # Overwrites upcoming history items (if @index < @history.length)
    if (@index < @history.length - 1)
      difference = (@history.length - @index) - 1
      @history.splice(-difference)

    # Push new command
    @history.push(command)
    @index = @history.length - 1

    this.handleStatusChange()

  undo: (times=1) ->
    return unless this.status().canUndo

    for i in [1..times]
      return unless @history[@index]

      this.down(@history[@index])
      @index--

      this.handleStatusChange()

  redo: (times=1) ->
    return unless this.status().canRedo

    for i in [1..times]
      return unless @history[@index + 1]

      @index++
      this.up(@history[@index])

      this.handleStatusChange()

  # Execute up/down on a command
  # command can be a group of commands or a single command
  exec: (action, command) ->
    return command[action]() unless command instanceof Array
    c[action]() for c in command

  up:   (command) -> this.exec('up',   command)
  down: (command) -> this.exec('down', command)

  # Status management
  onStatusChange: (callback) ->
    @statusChangeCallback = callback
    this.handleStatusChange()

  handleStatusChange: ->
    return unless @statusChangeCallback
    @statusChangeCallback(this.status())

  status: ->
    canUndo: @index > -1
    canRedo: @index < @history.length - 1

# Singleton
@CommandZ = new CommandZ
