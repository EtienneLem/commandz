window.CommandZ = require('commandz')
var $container = $('div'),
    buttons = {
      undo: document.getElementById('undo'),
      redo: document.getElementById('redo')
    }

// Capitalize
String.prototype.capitalize = function() {
 return this.charAt(0).toUpperCase() + this.slice(1)
}

// Add
var addCount = 0
window.add = function() {
  addCount++; var $i = $('<i>' + addCount + '</i>')

  CommandZ.execute({
    up:   function() { $container.append($i) },
    down: function() { $i.detach() }
  })
}

// Lets do 5 commands
for (var i = 0; i < 5; i++) { add() }

// Handle status
CommandZ.onStatusChange(function(status) {
  var actions = ['undo', 'redo']

  for (var i = 0; i < actions.length; i++) {
    var action = actions[i],
        canDo = status['can' + action.capitalize()],
        button = buttons[action]

    if (canDo) { attributes = ['_href', 'href'] }
    else       { attributes = ['href', '_href'] }

    attrToRemove = attributes[0]
    attrToAdd = attributes[1]

    if (button.hasAttribute(attrToRemove)) {
      button.setAttribute(attrToAdd, button.getAttribute(attrToRemove))
      button.removeAttribute(attrToRemove)
    }
  }
})
