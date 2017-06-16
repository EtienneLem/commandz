# Namespace
CommandZ = {}

# Client - Public API Singleton
class CommandZ.Client
  constructor: ->
    @VERSION = '0.2.0'

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
    nodeName = document.activeElement.nodeName
    return if nodeName is 'INPUT' || nodeName is 'TEXTAREA'
    return unless (e.which is 90 and e.metaKey is true || e.which is 26 and e.ctrlKey is true)

    e.preventDefault()
    if e.shiftKey then this.redo() else this.undo()

  # Execute and store actions
  execute: (actions) ->
    if Array.isArray(actions)
      spliceCount = 0
      for action, i in actions
        if action instanceof CommandZ.Action
          spliceCount++
        else
          actions[i] = new CommandZ.Action(action)
          actions[i].up()

      @history.splice(-spliceCount) if spliceCount
      historyItem = new CommandZ.Action(actions)
    else
      historyItem = new CommandZ.Action(actions)
      historyItem.up()

    this.addToHistory(historyItem)

  # Store data
  store: (data) ->
    data = new CommandZ.Data(data)
    this.addToHistory(data)

  # History management
  addToHistory: (historyItem) ->
    # Overwrite upcoming history items
    if @index < @history.length - 1
      difference = (@history.length - @index) - 1
      @history.splice(-difference)

    @history.push(historyItem)
    @index = @history.length - 1

    this.handleStatusChange()
    historyItem

  undo: (times=1) ->
    { canUndo } = this.status()
    return unless canUndo

    for i in [1..times]
      return unless historyItem = @history[@index]

      # Action
      historyItem.down() if historyItem instanceof CommandZ.Action

      # Has to be after an action item
      # but before a data item
      @index--
      historyItem = @history[@index]

      # Data
      this.handleData(historyItem.data) if historyItem instanceof CommandZ.Data

      this.handleStatusChange()

  redo: (times=1) ->
    { canRedo } = this.status()
    return unless canRedo

    for i in [1..times]
      return unless @history[@index + 1]

      # Has to be before both an action and a data item
      @index++
      historyItem = @history[@index]

      historyItem.up() if historyItem instanceof CommandZ.Action
      this.handleData(historyItem.data) if historyItem instanceof CommandZ.Data

      this.handleStatusChange()

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

    bottomLimit = if first instanceof CommandZ.Action then -1 else 0

    canUndo: @index > bottomLimit
    canRedo: @index < @history.length - 1

# Action
class CommandZ.Action
  constructor: (@actions) ->
    @actions = [@actions] unless Array.isArray(@actions)

  up:   -> this.upDown('up')
  down: -> this.upDown('down')

  upDown: (upDown) ->
    for action in @actions
      if _isFunction(action)
        action.call()
      else
        action[upDown]()

# Data
class CommandZ.Data
  constructor: (@data) ->

# Utils
# _isFunction
# https://github.com/jashkenas/underscore/blob/20e7c6e/underscore.js#L1333-L1340
if typeof /./ != 'function' && typeof Int8Array != 'object' && typeof document.childNodes != 'function'
  _isFunction = (obj) -> typeof obj == 'function'
else
  _isFunction = (obj) -> toString.call(action) == '[object Function]'

# Export
module.exports = new CommandZ.Client
