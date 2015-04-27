class CommandZ
  constructor: ->
    @VERSION = '0.1.2'

    this.reset()
    this.keyboardShortcuts(true)

  reset: ->
    this.clear()

    @statusChangeCallback = null
    @storageChangeCallback = null
    @thresholdTimer = null
    @threshold = 0

  clear: ->
    @history = []
    @index = -1

  keyboardShortcuts: (enable=true) ->
    addOrRemove = if enable then 'addEventListener' else 'removeEventListener'
    document[addOrRemove]('keydown', this.handleKeypress)

  handleKeypress: (e) =>
    return if document.activeElement.nodeName is 'INPUT'
    return unless (e.which is 90 and e.metaKey is true || e.which is 26 and e.ctrlKey is true)

    e.preventDefault()
    if e.shiftKey then this.redo() else this.undo()

  # Execute and store commands as { command: {up: ->, down: ->} }
  execute: (command) ->
    historyItem = {}
    historyItem.command = command

    this.up(command)
    this.addToHistory(historyItem)

  # Store data as { data: … }
  store: (data) ->
    historyItem = {}
    historyItem.data = data

    this.addToHistory(historyItem)

  # History management
  addToHistory: (historyItem) ->
    # Overwrite upcoming history items
    if @index < @history.length - 1
      difference = (@history.length - @index) - 1
      @history.splice(-difference)

    @history.push(historyItem)
    @index = @history.length - 1

    this.handleStatusChange()

  undo: (times=1) ->
    return unless this.status().canUndo

    for i in [1..times]
      return unless @history[@index]

      historyItem = @history[@index]
      this.down(command) if command = historyItem.command

      # Has to be after a command item, but before a data item
      @index--

      if historyItem = @history[@index]
        this.handleData(data) if data = historyItem.data

      this.handleStatusChange()

  redo: (times=1) ->
    return unless this.status().canRedo

    for i in [1..times]
      return unless @history[@index + 1]

      # Has to be before both a command and a data item
      @index++

      historyItem = @history[@index]
      this.up(command) if command = historyItem.command
      this.handleData(data) if data = historyItem.data

      this.handleStatusChange()

  # Execute up/down action on a command
  # command can be a group of commands or a single command
  exec: (action, command) ->
    return command[action]() unless command instanceof Array
    c[action]() for c in command

  up:   (command) -> this.exec('up',   command)
  down: (command) -> this.exec('down', command)

  # Send current history item data
  handleData: (data) ->
    return this.sendData(data) unless @threshold > 0

    clearTimeout(@thresholdTimer)
    @thresholdTimer = setTimeout =>
      this.sendData(data)
    , @threshold

  sendData: (data) ->
    return unless @storageChangeCallback
    @storageChangeCallback(data)

  # Storage management
  onStorageChange: (callback) ->
    @storageChangeCallback = callback

  setThreshold: (threshold) ->
    @threshold = threshold

  # Status management
  onStatusChange: (callback) ->
    @statusChangeCallback = callback
    this.handleStatusChange()

  handleStatusChange: ->
    return unless @statusChangeCallback
    @statusChangeCallback(this.status())

  status: ->
    first = @history[0]
    return { canUndo: false, canRedo: false } unless @history.length

    canUndo: if !!first.data then @index > 0 else @index > -1
    canRedo: @index < @history.length - 1

# Export singleton
module.exports = new CommandZ
