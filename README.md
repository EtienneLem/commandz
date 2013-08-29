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
</p>

## API
#### Glossary
```js
COMMANDS: An Array of COMMAND
COMMAND: {
  up:   function() {},
  down: function() {}
}
```

### execute
Receive `COMMAND` or `COMMANDS` and execute `COMMAND.up()`.

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

### undo
Call `COMMAND.down()` and set the index to the previous command.

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

### redo
Set the index to the next command and call `COMMAND.up()`.

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

### status
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

### clear
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

## DOM Example
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

## Setup
### Rails
1. Add `gem 'commandz'` to your Gemfile.
2. Add `//= require commandz` to your JavaScript manifest file.
3. Restart your server and `CMD+Z` - `CMD+SHIFT+Z` away!

### Other
Download and include [commandz.min.js](https://raw.github.com/EtienneLem/commandz/master/commandz.min.js) in your HTML pages.

## Tests
Run the `rake spec` task or `bundle exec guard` for continuous testing.
