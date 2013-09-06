<p align="center">
  <a href="https://github.com/EtienneLem/commandz">
    <img src="https://f.cloud.github.com/assets/436043/1047139/032acfc8-1059-11e3-8baa-d22caee7e517.png">
  </a>
</p>

<p align="center">
  <strong>CommandZ</strong> undo and redo commands.<br>
  Add commands history support to your web app.
</p>

<p align="center">
  <a href="http://badge.fury.io/rb/commandz"><img src="https://badge.fury.io/rb/commandz@2x.png" alt="Gem Version" height="18"></a>
  <a href="https://travis-ci.org/EtienneLem/commandz"><img src="https://travis-ci.org/EtienneLem/commandz.png" alt="Travis build"></a>
</p>

## Table of contents
- [API](#api)
  - [execute](#execute) | [store](#store)
  - [undo (commands)](#undo-commands) | [undo (storage)](#undo-storage)
  - [redo (commands)](#redo-commands) | [redo (storage)](#redo-storage)
  - [setThreshold (storage only)](#setthreshold-storage-only)
  - [status](#status)
  - [onStatusChange](#onstatuschange)
  - [onStorageChange](#onstoragechange)
  - [clear](#clear)
  - [reset](#reset)
  - [keyboardShortcuts](#keyboardshortcuts)
- [DOM Example](#dom-example)
  - [Commands](#commands)
  - [Storage](#storage)
- [Setup](#setup)
  - [Rails](#rails)
  - [Other](#other)
- [Tests](#tests)

## API
#### Glossary
```js
COMMANDS: An Array of COMMAND
COMMAND: {
  up:   function() {},
  down: function() {}
}
```

### #execute
Receive `COMMAND` or `COMMANDS` and execute `COMMAND.up()`.<br>
Store commands as a `{ command: COMMAND }` object in the history array.

**Single command per history item**<br>
Store one history item per `COMMAND`.

```js
CommandZ.execute({
  up:   function() { console.log('up 1') },
  down: function() { console.log('down 1') }
}) // => up 1

CommandZ.execute({
  up:   function() { console.log('up 2') },
  down: function() { console.log('down 2') }
}) // => up 2

console.log(CommandZ.commands.length) // => 2
console.log(CommandZ.index)           // => 1
```

**Multiple commands per history item**<br>
Store one history item per `COMMAND` group (`COMMANDS`).<br>
A *single* undo would go back through *all* of the `COMMAND` inside `COMMANDS`.

```js
commands = []
for (var i=1; i <= 5; i++) {
  commands.push({
    up:   function() { 'up 1.' + i },
    down: function() { 'down 1.' + i }
  })
}

CommandZ.execute(commands) // => up 1.1, up 1.2, up 1.3, up 1.4, up 1.5

console.log(CommandZ.commands.length) // => 1
console.log(CommandZ.index)           // => 0
```

### #undo (commands)
Call `COMMAND.down()` and set the index to the previous history item.

```js
CommandZ.execute({
  up:   function() { console.log('up 1') },
  down: function() { console.log('down 1') }
}) // => up 1

CommandZ.execute({
  up:   function() { console.log('up 2') },
  down: function() { console.log('down 2') }
}) // => up 2

CommandZ.undo() // => down 2

console.log(CommandZ.commands.length) // => 2
console.log(CommandZ.index)           // => 0

CommandZ.undo() // => down 1

console.log(CommandZ.commands.length) // => 2
console.log(CommandZ.index)           // => -1
```

### #redo (commands)
Set the index to the next history item and call `COMMAND.up()`.

```js
CommandZ.execute({
  up:   function() { console.log('up 1') },
  down: function() { console.log('down 1') }
}) // => up 1

CommandZ.execute({
  up:   function() { console.log('up 2') },
  down: function() { console.log('down 2') }
}) // => up 2

CommandZ.undo(2) // => down 2, down 1
CommandZ.redo()  // => up 1

console.log(CommandZ.commands.length) // => 2
console.log(CommandZ.index)           // => 0
```

### #store
Store data as a `{ data: … }` object in the history array.

```js
CommandZ.store({ width: 100, height: 100 })
```

### #undo (storage)
Set the index to the previous history item and send data via [`CommandZ.onStorageChange`](#onstoragechange).

```js
CommandZ.onStorageChange(function(data) {
  console.log(data)
})

CommandZ.store({ width: 100, height: 100 })
CommandZ.undo()

console.log(CommandZ.commands.length) // => 1
console.log(CommandZ.index)           // => -1

CommandZ.store({ width: 100, height: 100 })
CommandZ.store({ width: 200, height: 200 })
CommandZ.undo() // => { width: 100, height: 100 }

console.log(CommandZ.commands.length) // => 2
console.log(CommandZ.index)           // => 0
```

### #redo (storage)
Set the index to the next history item and send data via [`CommandZ.onStorageChange`](#onstoragechange).

```js
CommandZ.onStorageChange(function(data) {
  console.log(data)
})

CommandZ.store({ width: 100, height: 100 })
CommandZ.store({ width: 200, height: 200 })
CommandZ.undo() // => { width: 100, height: 100 }
CommandZ.redo() // => { width: 200, height: 200 }

console.log(CommandZ.commands.length) // => 2
console.log(CommandZ.index)           // => 1
```

### #setThreshold (storage only)
Unlike commands, you can allow your users to spam the `CMD+Z` button without restoring every states at every steps.<br>
Threshold is set in `milliseconds`.

```js
CommandZ.setThreshold(500)
CommandZ.onStorageChange(function(data) {
  console.log(data)
})

CommandZ.store({ width: 100, height: 100 })
CommandZ.store({ width: 200, height: 200 })
CommandZ.store({ width: 300, height: 300 })

CommandZ.undo(100)

// Wait 500ms
// => { width: 100, height: 100 }
```

### #status
Return the current status.

```js
CommandZ.execute({
  up:   function() { console.log('up 1') },
  down: function() { console.log('down 1') }
}) // => up 1

CommandZ.execute({
  up:   function() { console.log('up 2') },
  down: function() { console.log('down 2') }
}) // => up 2

console.log(CommandZ.status())        // => { canUndo: true, canRedo: false }
console.log(CommandZ.commands.length) // => 2
console.log(CommandZ.index)           // => 1
```

### #onStatusChange
Register a callback that will be called with the `status` every time there’s a change to the history.

```js
CommandZ.onStatusChange(function(status) {
  console.log(status)
})

CommandZ.execute({
  up:   function() { 'up 1' },
  down: function() { 'down 1' }
}) // => { canUndo: true, canRedo: false }

CommandZ.execute({
  up:   function() { 'up 2' },
  down: function() { 'down 2' }
}) // => { canUndo: true, canRedo: false }

CommandZ.undo() // => { canUndo: true, canRedo: true }
CommandZ.undo() // => { canUndo: false, canRedo: true }
```

### #onStorageChange
Register a callback that will be called with the `data` on undo/redo.

```js
CommandZ.onStorageChange(function(data) {
  console.log(data)
})

CommandZ.store({ width: 100, height: 100 })
CommandZ.store({ width: 200, height: 200 })

CommandZ.undo() // => { width: 100, height: 100 }
```

### #clear
Clear history.

```js
CommandZ.execute({
  up:   function() { console.log('up 1') },
  down: function() { console.log('down 1') }
}) // => up 1

CommandZ.execute({
  up:   function() { console.log('up 2') },
  down: function() { console.log('down 2') }
}) // => up 2

CommandZ.clear()

console.log(CommandZ.status())        // => undefined
console.log(CommandZ.commands.length) // => 0
console.log(CommandZ.index)           // => -1
```

### #reset
Clear history, remove callbacks and set threshold to 0.

### #keyboardShortcuts
Enable or disable `CMD+Z` & `CMD+SHIFT+Z` keyboard shortcuts. These shortcuts are enabled by default.<br>
Will only `undo()` & `redo()` if the current selected element is not an input so that it doesn’t prevent your OS default behavior.

```js
CommandZ.keyboardShortcuts(true) // default
CommandZ.keyboardShortcuts(false)
```

## DOM Example
### Commands
```js
// This example requires jQuery or Zepto
$container = $('<div></div>')

// Lets do 5 commands
[1, 2, 3, 4, 5].forEach(function(i) {
  var $i = $('<i>' + i + '</i>')
  CommandZ.execute({
    up:   function() { $container.append($i) },
    down: function() { $i.detach() } // When removing DOM elements, I highly recommend .detach()
  })
})

console.log($container.html()) // => <i>1</i><i>2</i><i>3</i><i>4</i><i>5</i>

// Undo
CommandZ.undo()
console.log($container.html()) // => <i>1</i><i>2</i><i>3</i><i>4</i>

// Redo
CommandZ.redo()
console.log($container.html()) // => <i>1</i><i>2</i><i>3</i><i>4</i><i>5</i>

// When undoing, a new command will overwrite all upcoming commands
CommandZ.undo(3)

$i = $('<i>1337</i>')
CommandZ.execute({
  up:   function() { $container.append($i) },
  down: function() { $i.detach() }
})

console.log($container.html())        // => <i>1</i><i>2</i><i>1337</i>
console.log(CommandZ.commands.length) // => 3
console.log(CommandZ.index)           // => 2
```

### Storage
```js
// This example requires jQuery or Zepto
$container = $('<div></div>')

img = new Image
$container.html(img)

// Register undo/redo callback
CommandZ.onStorageChange = function(data) {
  img.width = data.width
  img.height = data.height
}

img.width = 100
img.height = 100

// Lets store some states
[1, 2, 3, 4].forEach(function(i) {
  CommandZ.store({ width: i * 100, height: i * 100 })
})

CommandZ.undo(2)
console.log(img.width) // => 200

CommandZ.redo()
console.log(img.width) // => 300
```

## Setup
### Rails
1. Add `gem 'commandz'` to your Gemfile.
2. Add `//= require commandz` to your JavaScript manifest file.
3. Restart your server and `CMD+Z` - `CMD+SHIFT+Z` away!

### Other
Download and include [commandz.min.js](https://raw.github.com/EtienneLem/commandz/master/commandz.min.js) in your HTML pages. CommandZ is also hosted on [cdnjs.com](http://cdnjs.com).

## Tests
Run the `rake spec` task or `bundle exec guard` for continuous testing.
